require File.dirname(__FILE__) + '/abstract_unit'

class DateTimeTest < Test::Unit::TestCase
  fixtures :people
  
  def test_no_date_checking
    assert p.update_attributes(:date_of_birth => nil, :date_of_death => nil)
  end
  
  # Test basic format, 2006-01-01 17:30:30
  def test_first_format
    assert p.update_attributes(:date_and_time => '2006-01-01 01:01:01')
  end
end
