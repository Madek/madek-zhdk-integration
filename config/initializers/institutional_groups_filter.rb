InstitutionalGroup.class_eval do

  if Settings.zhdk_integration

    scope :selectable, lambda{
      where("institutional_group_name ~* '\.alle$'")
      .where("institutional_group_name !~* '^[Dd]ozierende\.'")
      .where("institutional_group_name !~* '^[Mm]ittelbau\.'")
      .where("institutional_group_name !~* '^[Pp]ersonal\.'")
      .where("institutional_group_name !~* '^[Ss]tudierende\.'")
      .where("institutional_group_name !~* '^[Vv]erteilerliste\.'")
    }

    def to_s
      "#{name} (#{institutional_group_name})"
    end

  end

end
