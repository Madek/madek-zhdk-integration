require "madek_zhdk_integration/engine"
require 'json'

module MadekZhdkIntegration

  def self.zhdk_ldap_data
    file= File.open(File.absolute_path(File.dirname(__FILE__) + "/../data/ldap.json"))
    JSON.load file
  end

end
