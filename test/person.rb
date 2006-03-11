class Person < ActiveRecord::Base
  def self.columns()
    @columns ||= []
  end
  
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :name
  column :date_of_birth, :date
  column :date_of_death, :date
  column :time_of_birth, :time
  column :time_of_death, :time
  
  validates_presence_of :name
  
  validates_date :date_of_birth, :if => Proc.new { |p| p.date_of_birth? }
  validates_time :time_of_birth, :if => Proc.new { |p| p.time_of_birth? }
  
  # Want to be able to use update_attributes
  def save
    valid?
  end
end
