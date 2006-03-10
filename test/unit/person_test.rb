

class PersonTest < Test::Unit::TestCase
  def test_no_date_checking
    p = Person.new(:name => 'Jonathan')
    assert p.valid?
    
    p.date_of_birth = p.date_of_death = nil
    assert p.valid?
  end
end
