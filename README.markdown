validates_date_time
===================
This plugin adds the ability to do stricter date and time checking with ActiveRecord.

This fork is patched to work with Rails 3.0.

Install
=======

Put this in your Gemfile:

```ruby
gem "validates_date_time", :git => "git://github.com/sofatutor/validates_date_time", :branch => 'rails-3'
```

Instructions
============
The validators can be used to parse strings into Date and Time objects as well as restrict  
an attribute based on other dates or times.
    class Person < ActiveRecord::Base
      validates_date     :date_of_birth
      validates_time     :time_of_birth
      validates_date_time :date_and_time_of_birth
    end
  
Use `:allow_nil` to allow the value to be blank.
    class Person < ActiveRecord::Base
      validates_date :date_of_birth, :allow_nil => true
    end
  
Supported formats
=================
The default for the plugin is to expect dates in day/month/year format. If you are in the
US, you will want to change the default to month/day/year by placing the following in config/environment.rb
    ValidatesDateTime.us_date_format = true
  
Date format examples:
 - 2006-01-01
 - 1 Jan 06
 - 1 Jan 2006
 - 10/1/06
 - 1/1/2006
  
Time format examples:
 - 1pm
 - 10:11
 - 12:30pm
 - 8am

Datetime format examples:
 - 1 Jan 2006 2pm
 - 31/1/06 8:30am

Examples
========
If an attribute value can not be parsed correctly, an error is added: 
    p = Person.new
    p.date_of_birth = "1 Jan 2006"
    p.time_of_birth = "5am"
    p.save # true

    p.date_of_birth = "30 Feb 2006"
    p.save # false, 30 feb is invalid for obvious reasons

    p.date_of_birth = "java is better than ruby"
    p.save # false
  
In the final example, as I'm sure you are aware, the record failed to save not only
because "java is better than ruby" is an invalid date, but more importantly, because the statement is blatantly false. ;) 

Restricting date and time ranges
================================
Using the `:before` and `:after` options you can restrict a date or time value based on other attribute values  
and predefined values. You can pass as many value to :before or :after as you like.
    class Person
      validates_date :date_of_birth, :before => [:date_of_death, Proc.new { 1.day.from_now_to_date}], :after => '1 Jan 1900'
      validates_date :date_of_death, :before => Proc.new { 1.day.from_now.to_date }
    end
  
    p = Person.new
    p.date_of_birth = '1800-01-01'
    p.save  # false
    p.errors[:date_of_birth] # must be after 1 Jan 1900

    p.date_of_death = Date.new(2010, 1, 1)
    p.save  # false
    p.errors[:date_of_death] # must be before <1 day from now>

    p.date_of_birth = '1960-03-02'
    p.date_of_death = '2003-06-07'
    p.save  # true
  
You can customise the error messages for dates or times that fall outside the required range. The boundary date will be substituted in for %s. Eg:
    class Person
      validates_date :date_of_birth, :after => Date.new(1900, 1, 1), :before => Proc.new { 1.day.from_now.to_date }, :before_message => 'Ensure it is before %s', :after_message => 'Ensure it is after %s'
    end

Author
======
If you find this plugin useful, please consider a donation to [show your support](http://www.paypal.com/cgi-bin/webscr?cmd=_send-money)!
Suggestions, comments, problems are all welcome. You'll find me at jonathan.viney@gmail.com