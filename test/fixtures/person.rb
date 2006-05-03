class Person < ActiveRecord::Base
  validates_date :date_of_birth,   :if => Proc.new { |p| p.date_of_birth? }
  validates_date :date_of_death,   :if => Proc.new { |p| p.date_of_death? }, :before => Proc.new { 1.day.from_now.to_date }, :after => :date_of_birth
  
  validates_date :date_of_arrival, :if => Proc.new { |p| p.date_of_arrival? }, :before => :date_of_departure, :after => '1 Jan 1800', :before_message => "avant %s", :after_message => "apres %s"
  
  validates_time :time_of_birth, :if => Proc.new { |p| p.time_of_birth? }
  
  validates_date_time :date_and_time_of_birth, :if => Proc.new { |p| p.date_and_time_of_birth? }
end
