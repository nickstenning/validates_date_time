require File.dirname(__FILE__) + '/lib/validates_date_time'

ActiveRecord::Base.send(:include, ActiveRecord::Validations::DateTime)
