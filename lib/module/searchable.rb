require_relative '../db_connection'
require_relative '../sql_object'

module Searchable
  def where(params)
    where_string = params.map do |key, value|
      "#{key} = ?"
    end.join(" AND ")

    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_string}
    SQL

    parse_all(results)
  end
end
