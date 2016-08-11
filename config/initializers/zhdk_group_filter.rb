Group.class_eval do

  if Settings.zhdk_integration

    scope :filter_by, lambda{ |search_term, filter = nil, _scope = nil|
      binding.pry
      query = default_query(search_term, filter)
      zhdk_query(query, search_term, filter, _scope)
    }

    private

    def self.zhdk_query(query, search_term, filter, _scope)

      if _scope == 'metadata'
        sql = <<-SQL
          ((type = 'InstitutionalGroup' AND #{InstitutionalGroup.filter_sql})
            OR type ='Group')
        SQL
        query = query.where(sql)
      else
        query
      end
    end
  end
end
