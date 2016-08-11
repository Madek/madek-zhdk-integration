InstitutionalGroup.class_eval do

  def self.filter_sql
    <<-SQL
      institutional_group_name ~* '\.alle$'
      AND institutional_group_name !~* '^[Dd]ozierende\.'
      AND institutional_group_name !~* '^[Mm]ittelbau\.'
      AND institutional_group_name !~* '^[Pp]ersonal\.'
      AND institutional_group_name !~* '^[Ss]tudierende\.'
      AND institutional_group_name !~* '^[Vv]erteilerliste\.'
    SQL
  end

  if Settings.zhdk_integration

    scope :selectable, lambda{
      where(filter_sql)
    }

    def to_s
      "#{name} (#{institutional_group_name})"
    end

  end

end
