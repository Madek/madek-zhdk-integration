Group.class_eval do

  if Settings.zhdk_integration

    scope :filter_by, lambda{ |search_term, filter = nil, query_scope = nil|
      query = default_query(search_term, filter)
      zhdk_query(query, search_term, filter, query_scope)
    }

    private

    def self.zhdk_query(query, _search_term, _filter, query_scope)
      if query_scope == 'metadata'
        sql = <<-SQL
          ((type = 'InstitutionalGroup' AND #{InstitutionalGroup.filter_sql})
            OR type ='Group')
        SQL
        query.where(sql)
      else
        query
      end
    end
  end
end
