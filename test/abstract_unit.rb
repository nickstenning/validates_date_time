require 'test/unit'
require 'rubygems'
require_gem 'activerecord'

require File.dirname(__FILE__) + '/../lib/validates_date_time'
require File.dirname(__FILE__) + '/person'

ActiveRecord::Base.send(:include, ActiveRecord::Validations::DateTime)

class Test::Unit::TestCase
 private
  def jonathan(attributes = {})
    p = Person.new({ :name => 'Jonathan' }.merge(attributes))
    assert p.valid?
    p
  end
end
