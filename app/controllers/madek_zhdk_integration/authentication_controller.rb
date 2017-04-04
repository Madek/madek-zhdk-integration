# -*- encoding : utf-8 -*-
require 'net/http'
require 'net/https'
require 'cgi'

class MadekZhdkIntegration::AuthenticationController < ApplicationController
  include Concerns::MadekCookieSession

  # never ever change the following property; database p- and fkeys depend on it
  ZHDK_USERS_GROUP_ID = UUIDTools::UUID.sha1_create Madek::Constants::MADEK_UUID_NS, 'ZHdK users'

  AGW_API_URL = Settings.zhdk_agw_api_url
  AGW_API_SECRET = Settings.zhdk_agw_api_key
  ZHDK_ADMIN_IDS = Settings.zhdk_admin_ids

  def login
    fail 'missing AGW url!' if AGW_API_URL.nil?
    fail 'missing AGW key!' if AGW_API_SECRET.nil?
    redirect_to build_auth_url
  end

  def build_auth_url
    "#{AGW_API_URL}&url_home=#{request.referer}&url_postlogin=#{postlogin_params}"
  end

  def postlogin_params
    CGI::escape(
      "#{request.base_url}#{postlogin_path_part}?return_to=#{request.referer}")
  end

  def postlogin_path_part
    url_for(relative_url_root + '/login/zhdk/login_successful/%s').to_s
  end

  def relative_url_root
    Rails.application.config.action_controller.relative_url_root.presence || ''
  end

  def login_successful(session_id = params[:id])
    response = fetch("#{AGW_API_URL}/response&agw_sess_id=#{session_id}" \
                     "&app_ident=#{AGW_API_SECRET}")
    if response.code.to_i == 200
      xml = Hash.from_xml(response.body)
      user = create_or_update_user(xml['authresponse']['person'])
      set_madek_session user, true
      promote_to_admin user if ZHDK_ADMIN_IDS.include? user.zhdkid
      # build success message, possibly provided by AGW:
      agw_message = 'ZHdK Login: ' + \
        xml['authresponse']['result'].try(:[], 'msg').presence || 'OK'
      # *always* clear the flash!
      flash.discard
      # redirect to original request target, force GET with 303, flash the message
      redirect_to (params[:return_to].presence || root_path),
                  status: 303, notice: agw_message
    else
      render plain: 'Authentication Failure. HTTP connection failed ' \
        " - response was #{response.code}", status: 500
    end
  end

  private

  def promote_to_admin(user)
    unless user.admin
      Admin.create user: user
    end
  end

  def fetch(uri_str, limit = 10)
     raise ArgumentError, 'HTTP redirect too deep' if limit == 0

     uri = URI.parse(uri_str)
     http = Net::HTTP.new(uri.host, uri.port)
     http.use_ssl = true if uri.port == 443
     response = http.get(uri.path + '?' + uri.query)
     case response
     when Net::HTTPSuccess     then response
     when Net::HTTPRedirection then fetch(response['location'], limit - 1)
     else
         response.error!
     end
  end

  def create_or_update_user(xml)
    user = User.find_by_zhdkid(xml['id'])
    if user.nil?
      login = xml['local_username']
      email = xml['email']
      # remove existing equivalent logins
      User.where(login: login).find_each do |user|
        user.update_attributes! login: nil
      end
      # remove existing equivalent emails
      User.where('lower(email) = lower(?)', email).find_each do |user|
        user.update_attributes! email: nil
      end
      person = Person.find_or_create_by(subtype: 'Person',
                                        first_name: xml['firstname'],
                                        last_name: xml['lastname'])
      user = person.create_user login: login, email: email,
                                zhdkid: xml['id'], password: SecureRandom.base64
    end

    if user
      groups = Array(xml['memberof']['group'])
      g = groups.map { |x| x.gsub('zhdk/', '') }
      new_groups = InstitutionalGroup.where(institutional_group_name: g)
      to_add = (new_groups - user.groups.departments)
      to_remove = (user.groups.departments - new_groups)
      user.groups << to_add
      user.groups.delete(to_remove)

      zhdk_group = AuthenticationGroup.find_or_initialize_by id: ZHDK_USERS_GROUP_ID
      zhdk_group.name ||= 'ZHdK (Zürcher Hochschule der Künste)'
      zhdk_group.save! unless zhdk_group.persisted?
      zhdk_group.users << user unless zhdk_group.users.include?(user)
    end

    user
  end

end
