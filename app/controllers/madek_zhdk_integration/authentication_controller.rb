# -*- encoding : utf-8 -*-
require 'net/http' 
require 'net/https'
require 'cgi'

class MadekZhdkIntegration::AuthenticationController < ApplicationController
  include Concerns::SetSession

  AUTHENTICATION_URL = 'http://www.zhdk.ch/?auth/madek'
  APPLICATION_IDENT = 'fc7228cdd9defd78b81532ac71967beb'
    
  def login
    target = AUTHENTICATION_URL + "&url_postlogin=" + CGI::escape("http://#{request.host}:#{request.port}#{url_for('/authenticator/zhdk/login_successful/%s')}")
    redirect_to target
  end

  def login_successful(session_id = params[:id])
    response = fetch("#{AUTHENTICATION_URL}/response&agw_sess_id=#{session_id}&app_ident=#{APPLICATION_IDENT}")
    if response.code.to_i == 200
      xml = Hash.from_xml(response.body)
      set_madek_session create_or_update_user(xml["authresponse"]["person"])
      redirect_to root_path
    else
      render :text => "Authentication Failure. HTTP connection failed - response was #{response.code}" 
    end
  end

  def logout
    reset_session
    flash[:notice] = "Sie haben sich abgemeldet." #"You have been logged out."
    redirect_to root_path
  end
      
  private 
  
  def fetch(uri_str, limit = 10)
     raise ArgumentError, 'HTTP redirect too deep' if limit == 0

     uri = URI.parse(uri_str)
     http = Net::HTTP.new(uri.host, uri.port)
     http.use_ssl = true if uri.port == 443
     response = http.get(uri.path + "?" + uri.query)
     case response
     when Net::HTTPSuccess     then response
     when Net::HTTPRedirection then fetch(response['location'], limit - 1)
     else
         response.error!
     end
  end

  def create_or_update_user(xml)
    user = User.find_by_zhdkid(xml["id"]) # TODO use xml["uniqueid"] ??
    if user.nil?
      person = Person.find_or_create_by(:first_name => xml["firstname"],
                                                               :last_name => xml["lastname"])
      user = person.create_user login: xml["local_username"], email: xml["email"], zhdkid: xml["id"], password: SecureRandom.base64
    end
    if user
      groups = Array(xml['memberof']['group'])
      g = groups.map {|x| x.gsub("zhdk/", "") }
      new_groups = InstitutionalGroup.where(:institutional_group_name => g)
      to_add = (new_groups - user.groups.departments)
      to_remove = (user.groups.departments - new_groups)
      user.groups << to_add
      user.groups.delete(to_remove)
      
      zhdk_group = Group.find_or_create_by(:name => "ZHdK (Zürcher Hochschule der Künste)")
      user.groups << zhdk_group unless user.groups.include?(zhdk_group) 
      
      user
    end
  end
  
end
