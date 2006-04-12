require File.dirname(__FILE__) + '/abstract_unit'

class TimeTest < Test::Unit::TestCase
  fixtures :people
  
  def test_no_time_checking
    assert p.update_attributes(:time_of_birth => nil, :time_of_death => nil, :time_of_death => 'Silver Ferns')
  end
  
  def test_with_seconds
    assert_update_and_match(:time_of_birth, '03:45:22', /03:45:22/)
  end
  
  def test_12_hour_with_minute
    { '7.20pm' => /19:20:00/, ' 1:33 AM' => /01:33:00/, '11 28am' => /11:28:00/ }.each do |value, result|
      assert_update_and_match(:time_of_birth, value, result)
    end
  end
  
  def test_12_hour_without_minute
    { '11 am' => /11:00:00/, '7PM ' => /19:00:00/, ' 1Am' => /01:00:00/ }.each do |value, result|
      assert_update_and_match(:time_of_birth, value, result)
    end
  end
  
  def test_24_hour
    { '22:00' => /22:00:00/, '10 23' => /10:23:00/, '01 01' => /01:01:00/ }.each do |value, result|
      assert_update_and_match(:time_of_birth, value, result)
    end
  end
  
  def test_time_objects
    { Time.gm(2006, 2, 2, 22, 30) => /22:30:00/, '2pm' => /14:00:00/, Time.gm(2006, 2, 2, 1, 3) => /01:03:00/ }.each do |value, result|
      assert_update_and_match(:time_of_birth, value, result)
    end
  end
  
  def test_invalid_formats
    ['1 PPM', 'lunchtime', '8..30', 'chocolate'].each do |value|
      assert !p.update_attributes(:time_of_birth => value)
    end
  end
end
