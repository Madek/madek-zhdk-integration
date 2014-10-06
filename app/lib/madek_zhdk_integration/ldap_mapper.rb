module MadekZhdkIntegration
  module LdapMapper

    class << self

      def reload! 
        load Rails.root.join(__FILE__)
      end

      def module_path # for convenient reloading
        Rails.root.join(__FILE__)
      end


      def create_map 
        File.open(Rails.root.join("tmp","ldap_map.yml"),"w") do |file|
          file.write(
            Hash[
              InstitutionalGroup.all.map do |g| 
                [g.institutional_group_name,g.name.gsub(/\n/, " ").strip]
              end.sort].to_yaml(line_width: -1))
        end
      end

    end
  end
end
