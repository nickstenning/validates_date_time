require 'test/unit'
require 'rubygems'
require_gem 'activerecord'

require File.dirname(__FILE__) + '/../../lib/validates_date'

ActiveRecord::Base.send(:include, ActiveRecord::Validations::Date)
