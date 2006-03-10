require File.dirname(__FILE__) + '/abstract_unit'

class Person < ActiveRecord::Base
  def self.columns()
    @columns ||= []
  end
  
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :name
  column :date_of_birth
  column :date_of_death
  
  validates_presence_of :name
  validates_date :date_of_birth, :if => Proc.new { |p| p.date_of_birth? }
  
  # Want to be able to use update_attributes
  def save
    valid?
  end
end


class PersonTest < Test::Unit::TestCase
  def test_no_date_checking
    p = jonathan
    
    assert p.update_attributes(:date_of_birth => nil, :date_of_death => nil)
    assert p.update_attributes(:date_of_death => 'All Blacks')
  end
  
  # Test 1/1/06 format
  def test_first_format
    p = jonathan
    
    assert p.update_attributes(:date_of_birth => '1/1/01')
    assert_equal '2001-01-01', p.date_of_birth.to_s
    
    assert p.update_attributes(:date_of_birth => '29/10/2005')
    assert_equal '2005-10-29', p.date_of_birth.to_s
    
    # Feb 30 should be invalid
    assert !p.update_attributes(:date_of_birth => '30/2/06')
  end
  
  # Test 1 Jan 06 format
  def test_second_format
    p = jonathan
    
    assert p.update_attributes(:date_of_birth => '16 MaR 60')
    assert_equal '1960-03-16', p.date_of_birth.to_s
    
    assert p.update_attributes(:date_of_birth => '22 dec 1985')
    assert_equal '1985-12-22', p.date_of_birth.to_s
    
    assert !p.update_attributes(:date_of_birth => '1 Jaw 00')
  end
  
  def test_invalid_formats
    p = jonathan
    
    assert !p.update_attributes(:date_of_birth => 'aksjhdaksjhd')
    assert !p.update_attributes(:date_of_birth => 'meow')
    assert !p.update_attributes(:date_of_birth => 'chocolate')
    
    assert !p.update_attributes(:date_of_birth => '221 jan 05')
    assert !p.update_attributes(:date_of_birth => '21 JAN 001')
    
    assert !p.update_attributes(:date_of_birth => '1/2/3/4')
    assert !p.update_attributes(:date_of_birth => '11/22/33')
    assert !p.update_attributes(:date_of_birth => '10/10/990')
    assert !p.update_attributes(:date_of_birth => '189 /1 /9')
  end
  
 private
  def jonathan
    p = Person.new(:name => 'Jonathan')
    assert p.valid?
    p
  end
end
