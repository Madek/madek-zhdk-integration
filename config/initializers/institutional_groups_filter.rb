InstitutionalGroup.class_eval do

  if Settings.zhdk_integration 

    scope :selectable, lambda{
      where("institutional_group_name NOT SIMILAR TO '%_[0-9]{2}[A-Za-z]\.studierende'")
      .where("institutional_group_name NOT SIMILAR TO 'Verteilerliste\.%'")
      .where("institutional_group_name NOT SIMILAR TO 'Personal\.%'")
      .where("institutional_group_name !~* '^dozierende'")
      .where("institutional_group_name !~* '^mittelbau'")
      .where("institutional_group_name !~* '^personal'")
      .where("institutional_group_name !~* '^studirende'")
      .where("institutional_group_name !~* '^verteilerliste'")
    }

  end

end
