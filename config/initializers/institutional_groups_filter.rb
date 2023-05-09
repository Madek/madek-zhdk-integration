Rails.application.reloader.to_prepare do
  InstitutionalGroup.class_eval do

    def self.filter_sql
      <<-SQL
        institutional_name ~* '\.alle$'
        AND institutional_name !~* '^[Dd]ozierende\.'
        AND institutional_name !~* '^[Mm]ittelbau\.'
        AND institutional_name !~* '^[Pp]ersonal\.'
        AND institutional_name !~* '^[Ss]tudierende\.'
        AND institutional_name !~* '^[Vv]erteilerliste\.'
      SQL
    end

    if Settings.zhdk_integration

      scope :selectable, lambda{
        where(filter_sql)
      }

      def to_s
        "#{name} (#{institutional_name})"
      end

    end

  end
end
