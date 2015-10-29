#Rails Lite

##Active Record Lite

Unveils the 'magic' behind Active Record using Ruby's metaprogramming capabilities. Active Record was part one of re-building Rails, and it involved a deeper understanding of the Ruby language.

````ruby
class SQLObject
  extend Associatable
  extend Searchable

  def self.columns
    return @columns if @columns
    cols = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{table_name}
    SQL

    @columns = cols.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |col|
      define_method("#{col}=") do |value|
        self.attributes[col] = value
      end

      define_method("#{col}") do
        self.attributes[col]
      end
    end
  end
````
