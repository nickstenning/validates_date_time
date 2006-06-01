module ActiveRecord::Validations::DateTime
  def self.append_features(base)
    super
    base.extend(ClassMethods)
  end
  
  class DateParseError < StandardError #:nodoc:
  end
  class TimeParseError < StandardError #:nodoc:
  end
  class DateTimeParseError < StandardError #:nodoc:
  end
  class RestrictionError < StandardError #:nodoc:
  end
  
  mattr_accessor :us_date_format
  us_date_format = false
  
  module ClassMethods
   private
    [:date, :time].each do |method|
      class_eval <<-END
        def relative_#{method}_restrictions(configuration)
          [:before, :after].collect do |option|
            [configuration[option]].flatten.compact.collect do |item|
              case item
                when Symbol, Proc then item
                when #{method.to_s.camelize} then item
                when String then parse_#{method}(item)
                else raise RestrictionError, "\#{item.class}:\#{item} invalid. Use either a Proc, String, Symbol or #{method.to_s.camelize} object."
              end
            end
          end
        end
      END
      
      class_eval <<-END
        def #{method}_meets_relative_restrictions(value, record, restrictions, method)
          restrictions = restrictions.select do |restriction|
            begin
              case restriction
                when Symbol
                  value.send(method, record.send(restriction)) rescue false
                  
                when Proc
                  result = restriction.call(record)
                  result = parse_#{method}(result) unless result.is_a?(#{method.to_s.camelize})
                  value.send(method, result)
                  
                when #{method.to_s.camelize}
                  value.send(method, restriction)
                  
                else
                  raise
              end
            rescue
              raise RestrictionError, "Invalid restriction \#{restriction.class}:\#{restriction}"
            end
          end
          
          restrictions.collect { |r| r.respond_to?(:call) ? r.call(record) : r }.first
        end
      END
    end

    alias_method :relative_date_time_restrictions, :relative_time_restrictions
    
    def date_before(value, record, restrictions)
      date_meets_relative_restrictions(value, record, restrictions, :>)
    end
    
    def date_after(value, record, restrictions)
      date_meets_relative_restrictions(value, record, restrictions, :<=)
    end
    
    def time_before(value, record, restrictions)
      time_meets_relative_restrictions(value, record, restrictions, :>)
    end
    
    def time_after(value, record, restrictions)
      time_meets_relative_restrictions(value, record, restrictions, :<=)
    end
    
    alias_method :date_time_before, :time_before
    alias_method :date_time_after,  :time_after
    
   public
    [:date, :time, :date_time].each do |validator|
      class_eval <<-END
        def validates_#{validator}(*attr_names)
          configuration = { :message        => "is an invalid #{validator}",
                            :before_message => "must be before %s",
                            :after_message  => "must be after %s",
                            :on => :save }
          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
          
          configuration.assert_valid_keys :message, :before_message, :after_message, :before, :after, :if, :on
          
          before_restrictions, after_restrictions = relative_#{validator}_restrictions(configuration)
          
          validates_each(attr_names, configuration) do |record, attr_name, value|
            value_to_parse = record.send("\#{attr_name}_before_type_cast")
            
            value_to_parse = parse_date_time(value_to_parse) rescue value_to_parse
            
            begin
              result = parse_#{validator}(value_to_parse)
              
              if failed_restriction = #{validator}_before(result, record, before_restrictions)
                record.errors.add(attr_name, configuration[:before_message] % failed_restriction)
              end
              
              if failed_restriction = #{validator}_after(result, record, after_restrictions)
                record.errors.add(attr_name, configuration[:after_message] % failed_restriction)
              end
              
              record.send("\#{attr_name}=", result) unless record.errors.on(attr_name)
            rescue #{validator.to_s.camelize}ParseError
              record.errors.add(attr_name, configuration[:message])
            end
          end
        end
      END
    end
    
   private
    def parse_date(value)
      raise if value.blank?
      return value if value.is_a?(Date)
      return value.to_date if value.is_a?(Time)
      raise unless value.is_a?(String)
      
      year, month, day = case value.strip
        # 22/1/06 or 22\1\06
        when /^(\d{1,2})[\\\/\.:-](\d{1,2})[\\\/\.:-](\d{2}|\d{4})$/ then [$3, $2, $1]
        # 22 Feb 06 or 1 jun 2001
        when /^(\d{1,2}) (\w{3,9}) (\d{2}|\d{4})$/ then [$3, $2, $1]
        # July 1 2005
        when /^(\w{3,9} (\d{1,2}) (\d{2}|\d{4}))$/ then [$3, $1, $2]
        # 2006-01-01
        when /^(\d{4})-(\d{2})-(\d{2})$/ then [$1, $2, $3]
        # Not a valid date string
        else raise
      end
      
      month, day = day, month if ActiveRecord::Validations::DateTime.us_date_format
      
      Date.new(unambiguous_year(year), month_index(month), day.to_i)
    rescue
      raise DateParseError
    end
    
    def parse_time(value)
      raise if value.blank?
      return value if value.is_a?(Time)
      return value.to_time if value.is_a?(Date)
      raise unless value.is_a?(String)
      
      hour, minute, second = case value.strip
        # 12 hour with minute: 7.30pm, 11:20am, 2 20PM
        when /^(\d{1,2})[\. :](\d{2})\s?(am|pm)$/i
          [full_hour($1, $3), $2]
        # 12 hour without minute: 2pm, 11Am, 7 pm
        when /^(\d{1,2})\s?(am|pm)$/i
          [full_hour($1, $2)]
        # 24 hour: 22:30, 03.10, 12 30
        when /^(\d{2})[\. :](\d{2})([\. :](\d{2}))?/
          [$1, $2, $4]
        # Not a valid time string
        else raise
      end
      
      Time.send(ActiveRecord::Base.default_timezone, 2000, 1, 1, hour.to_i, minute.to_i, second.to_i)
    rescue
      raise TimeParseError
    end
    
    def parse_date_time(value)
      raise if value.blank?
      return value if value.is_a?(Time)
      return value.to_time if value.is_a?(Date)
      raise unless value.is_a?(String)
      
      value.strip!
      
      # The basic approach is to attempt to parse a date from the front of the string, splitting on spaces.
      # Once a date has been parsed, a time is extracted from the rest of the string.
      split_index = 0
      until false do
        split_index = value.index(' ', split_index == 0 ? 0 : split_index + 1)
        break if !split_index or (date = parse_date(value[0..split_index]) rescue nil)
      end
      
      time = parse_time(value[split_index + 1..value.size]) if split_index
      
      Time.send(ActiveRecord::Base.default_timezone, date.year, date.month, date.day, time.hour, time.min, time.sec)
    rescue
      raise DateTimeParseError
    end
    
    def full_hour(hour, meridian)
      hour = hour.to_i
      if meridian.strip.downcase == 'am'
        hour == 12 ? 0 : hour
      else
        hour == 12 ? hour : hour + 12
      end
    end
    
    def month_index(month)
      return month.to_i unless month.to_i.zero?
      Date::ABBR_MONTHNAMES.index(month.capitalize) || Date::MONTHNAMES.index(month.capitalize)
    end
    
    # Extract a 4-digit year from a 2-digit year.
    # If the number is less than 20, assume year 20#{number}
    # otherwise use 19#{number}. Ignore if already 4 digits.
    #
    # Eg:
    #    10 => 2010, 60 => 1960, 00 => 2000, 1963 => 1963
    def unambiguous_year(year)
      year = "#{year.to_i < 20 ? '20' : '19'}#{year}" if year.length == 2
      year.to_i
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Validations::DateTime)
