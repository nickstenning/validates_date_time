require 'test/unit'
require 'rubygems'
require_gem 'activerecord'

require File.dirname(__FILE__) + '/../lib/validates_date_time'

ActiveRecord::Base.send(:include, ActiveRecord::Validations::DateTime)

require File.dirname(__FILE__) + '/person'

class Test::Unit::TestCase
  attr_reader :p
  
  def setup
    @p = Person.new(:name => 'Jonathan')
    assert p.valid?
  end
end
