class ActiveRecord::Base
  def self.validates_date(*attr_names)
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
  def self.string_to_date(string)
    return string unless string.is_a?(String)
    
    string.strip!
    
    unless string =~ /^\d{4}-\d{2}-\d{2}/ # Skip if already in 2006-01-01 format
      # 22/1/06
      if string =~ /^(\d{1,2})\/(\d{1,2})\/(\d{2,4})$/
        day, month, year = $1, $2, $3
      end
      
      # 22 Feb 06
      if string =~ /^(\d{1,2}) (\w{3}) (\d{2,4})$/
        day, month, year = $1, $2, $3
        month = Date::ABBR_MONTHNAMES.index(month.capitalize)
      end
      
      year = year.to_i < 20 ? "20#{year}" : "19#{year}" if year.length == 2
      string = "#{year}-#{month}-#{day}"
    end
    
    date_array = ParseDate.parsedate(string)
    # treat 0000-00-00 as nil
    Date.new(date_array[0], date_array[1], date_array[2]) rescue nil
  end
end
