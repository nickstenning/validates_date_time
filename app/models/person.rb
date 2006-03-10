class Person < ActiveRecord::Base
  def self.columns()
    @columns ||= []
  end
  
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :name, :date_of_birth, :date_of_death
  
  validates_presence_of :name
  validates_date :date_of_birth
end