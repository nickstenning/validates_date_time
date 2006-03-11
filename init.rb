require File.dirname(__FILE__) + '/lib/validates_date'

ActiveRecord::Base.send(:include, ActiveRecord::Validations::DateTime)
