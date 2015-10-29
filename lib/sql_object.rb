require_relative 'db_connection'
require 'active_support/inflector'
require_relative 'module/searchable'
require_relative 'module/associatable'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

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

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    cats = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    parse_all(cats)
  end

  def self.parse_all(results)
    results.map { |params| self.new(params) }
  end

  def self.find(id)
    cat = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    parse_all(cat).first
  end

  def initialize(params = {})
    params.each do |col, value|
      col = col.to_sym
      if self.class.columns.include?(col)
        self.send("#{col}=", value)
      else
        raise "unknown attribute '#{col}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |col| self.send("#{col}") }
  end

  def insert
    cols = self.class.columns.drop(1)
    col_names = cols.join(", ")
    question_marks = (["?"] * cols.count).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    col_string = self.class.columns.drop(1).map { |col| "#{col} = ?" }.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.rotate(1))
      UPDATE
        #{self.class.table_name}
      SET
        #{col_string}
      WHERE
        id = ?
    SQL
  end

  def save
    if self.id.nil?
      insert
    else
      update
    end
  end
end
