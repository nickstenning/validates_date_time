module ActiveRecord::Validations::Date
  def self.append_features(base)
    super
    base.extend ClassMethods
  end
  
  module ClassMethods
    def validates_date(*attr_names)
      configuration = { :message => 'is an invalid date', :on => :save }
      configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
      
      validates_each(attr_names, configuration) do |record, attr_name, value|
        if date = string_to_date(value)
          record.send("#{attr_name}=", date)
        else
          record.errors.add(attr_name, configuration[:message])
        end
      end
    end
    
   private
    def string_to_date(string)
      return string unless string.is_a?(String)
      
      string.strip!
      
      case
        # 22/1/06
        when string =~ /^(\d{1,2})\/(\d{1,2})\/(\d{2}|\d{4})$/
          string = "#{ unambiguous_year $3 }-#{$2}-#{$1}"
        
        # 22 Feb 06 or 1 jun 2001
        when string =~ /^(\d{1,2}) (\w{3}) (\d{2}|\d{4})$/
          string = "#{ unambiguous_year $3 }-#{ Date::ABBR_MONTHNAMES.index($2.capitalize) }-#{$1}"
        
        # 2006-01-01, ignored
        when string =~ /^\d{4}-\d{2}-\d{2}$/
        
        # Not a valid date string
        else
          return nil
      end
      
      date_array = string.split('-').collect { |s| s.to_i }
      Date.new(date_array[0], date_array[1], date_array[2]) rescue nil
    end
    
    def unambiguous_year(year)
      year.length == 2 ? (year.to_i < 20 ? "20#{year}" : "19#{year}") : year
    end
  end
end
