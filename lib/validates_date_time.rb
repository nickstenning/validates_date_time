module ActiveRecord::Validations::DateTime
  def self.append_features(base)
    super
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def validates_date(*attr_names)
      configuration = { :message        => "is an invalid date",
                        :before         => Proc.new { 1.year.from_now.to_date },
                        :before_message => "must be before %s",
                        :after          => Date.new(1900, 1, 1),
                        :after_message  => "must be after %s",
                        :on => :save }
      configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
      
      validates_each(attr_names, configuration) do |record, attr_name, value|
        value_before_type_cast = record.send("#{attr_name}_before_type_cast")
        
        if result = parse_date_string(value_before_type_cast.to_s)
          if before = configuration[:before]
            before = before.call(record) if before.is_a?(Proc)
            unless before.nil?
              record.errors.add(attr_name, configuration[:before_message] % before) if result > before
            end
          end
          
          if after = configuration[:after]
            after = after.call(record) if after.is_a?(Proc)
            unless after.nil?
              record.errors.add(attr_name, configuration[:after_message] % after) if result < after
            end
          end                
            
          record.send("#{attr_name}=", result) unless record.errors.on(attr_name)
        else
          record.errors.add(attr_name, configuration[:message])
        end
      end
    end
    
    def validates_time(*attr_names)
      configuration = { :message => "is an invalid time", :on => :save }
      configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
      
      validates_each(attr_names, configuration) do |record, attr_name, value|
        value_before_type_cast = record.send("#{attr_name}_before_type_cast")
        
        unless value_before_type_cast.is_a?(Time)
          result = parse_time_string(value_before_type_cast.to_s)
          record.send("#{attr_name}=", result)
          record.errors.add(attr_name, configuration[:message]) unless result
        end 
      end        
    end
    
    def validates_datetime(*attr_names)
      configuration = { :message => "is an invalid datetime", :on => :save }
      configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
      
      validates_each(attr_names, configuration) do |record, attr_name, value|
        value_before_type_cast = record.send("#{attr_name}_before_type_cast")
        
        unless value_before_type_cast.is_a?(Time)
          result = parse_datetime_string(value_before_type_cast.to_s)
          record.send("#{attr_name}=", result)
          record.errors.add(attr_name, configuration[:message]) unless result
        end
      end
    end
    
   private
    # Attempt to parse a string into a Date object.
    # Return nil if parsing fails
    def parse_date_string(string)
      return if string.nil?
      
      year, month, day = case string.strip
        # 22/1/06
        when /^(\d{1,2})[\\\/\.:-](\d{1,2})[\\\/\.:-](\d{2}|\d{4})$/ then [$3, $2, $1]
        # 22 Feb 06 or 1 jun 2001
        when /^(\d{1,2}) (\w{3,9}) (\d{2}|\d{4})$/ then [$3, $2, $1]
        # July 1 2005
        when /^(\w{3,9} (\d{1,2}) (\d{2}|\d{4}))$/ then [$3, $1, $2]
        # 2006-01-01
        when /^(\d{4})-(\d{2})-(\d{2})$/ then [$1, $2, $3]
        # Not a valid date string
        else return
      end
      
      Date.new(unambiguous_year(year), month_index(month), day.to_i) rescue nil
    end
    
    # Attempt to parse a string into a Time object.
    # Return nil if parsing fails
    def parse_time_string(string)
      return if string.nil?
      
      hour, minute, second = case string.strip
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
        else return
      end
      
      Time.send(ActiveRecord::Base.default_timezone, 2000, 1, 1, hour.to_i, minute.to_i, second.to_i) rescue nil
    end
    
    # Attempt to parse a string into a date and time
    # Return nil if parsing fails
    def parse_datetime_string(string)
      return if string.nil?
      
      # The basic approach is to attempt to parse a date from the front of the string, splitting on spaces.
      # Once a date has been parsed, a time is extracted from the rest of the string.
      split_index = 0
      until false do
        split_index = string.index(' ', split_index == 0 ? 0 : split_index + 1)
        break if !split_index or date = parse_date_string(string[0..split_index])
      end
      
      time = parse_time_string(string[split_index + 1..string.size]) if split_index
      
      Time.send(ActiveRecord::Base.default_timezone, date.year, date.month, date.day, time.hour, time.min, time.sec) rescue nil
    end
    
    def full_hour(hour, meridian)
      meridian.strip.downcase == 'am' ? hour.to_i : hour.to_i + 12
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
