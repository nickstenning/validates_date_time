require File.dirname(__FILE__) + '/abstract_unit'

class TimeTest < Test::Unit::TestCase
  def test_no_time_checking
    p = jonathan
    
    assert p.update_attributes(:time_of_birth => nil, :time_of_death => nil)
    assert p.update_attributes(:time_of_death => 'Silver Ferns')
  end
  
  def test_with_seconds
    p = jonathan
    
    assert p.update_attributes(:time_of_birth => '03:45:22')
  end
  
  def test_12_hour_with_minute
    p = jonathan
    
    assert p.update_attributes(:time_of_birth => '7.20pm')
    assert_match /19:20:00/, p.time_of_birth.to_s
    
    assert p.update_attributes(:time_of_birth => ' 1:33 AM')
    assert_match /01:33:00/, p.time_of_birth.to_s
    assert p.valid?
    
    assert p.update_attributes(:time_of_birth => '11 28am')
    assert_match /11:28:00/, p.time_of_birth.to_s
  end
  
  def test_12_hour_without_minute
    p = jonathan
    
    assert p.update_attributes(:time_of_birth => '11 am')
    assert_match /11:00:00/, p.time_of_birth.to_s
    
    assert p.update_attributes(:time_of_birth => '7PM ')
    assert_match /19:00:00/, p.time_of_birth.to_s
    
    assert p.update_attributes(:time_of_birth => ' 1Am')
    assert_match /01:00:00/, p.time_of_birth.to_s
  end
  
  def test_24_hour
    p = jonathan
    
    assert p.update_attributes(:time_of_birth => '22:00')
    assert_match /22:00:00/, p.time_of_birth.to_s
    
    assert p.update_attributes(:time_of_birth => '10 23 ')
    assert_match /10:23:00/, p.time_of_birth.to_s
    assert p.valid?
    
    assert p.update_attributes(:time_of_birth => '01 01')
    assert_match /01:01:00/, p.time_of_birth.to_s
  end
  
  def test_time_objects
    p = jonathan
    
    assert p.update_attributes(:time_of_birth => Time.gm(2006, 2, 2, 22, 30))
    assert_match /22:30:00/, p.time_of_birth.to_s
    
    assert p.update_attributes(:time_of_birth => '2pm')
    assert_match /14:00:00/, p.time_of_birth.to_s
    
    assert p.update_attributes(:time_of_birth => Time.gm(2006, 2, 2, 1, 3))
    assert_match /01:03:00/, p.time_of_birth.to_s
  end
  
  def test_invalid_formats
    p = jonathan
    
    assert !p.update_attributes(:time_of_birth => '1 PPM')
    assert !p.update_attributes(:time_of_birth => 'lunchtime')
    assert !p.update_attributes(:time_of_birth => '8..30')
    assert !p.update_attributes(:time_of_birth => 'chocolate')
  end
end
