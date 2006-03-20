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
  column :date_of_visit, :date
  
  column :time_of_birth, :time
  column :time_of_death, :time
  
  validates_presence_of :name
  
  validates_date :date_of_birth, :if => Proc.new { |p| p.date_of_birth? }
  validates_date :date_of_visit, :if => Proc.new { |p| p.date_of_visit? },
                   :before => Proc.new { 1.day.from_now.to_date }, :after => Proc.new { Date.new(1900, 1, 1) }
  validates_time :time_of_birth, :if => Proc.new { |p| p.time_of_birth? }
  
  # Want to be able to use update_attributes
  def save
    valid?
  end
end
