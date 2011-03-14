require 'java'

module Bberg

  # path to where the bloomberg java API jar can be found.
  # 
  # either uses the path in the env variable BBERG_JAVA_HOME
  #  or defaults to 'C:/blp/API/APIv3/JavaAPI/v3.3.3.3/lib'
  # @return [String] path to jar
  def self.jar_path
    # load either from BBERG_JAVA_HOME or the default location
    base_path = ENV['BBERG_JAVA_HOME'].nil? ? 'C:/blp/API/APIv3/JavaAPI/v3.3.3.3/lib' : ENV['BBERG_JAVA_HOME']
    File.join(base_path, 'blpapi3.jar')
  end
  
  # Module to hold references to the native java API classes in a ruby friendly way.
  module Native
    require Bberg.jar_path
    import com.bloomberglp.blpapi.CorrelationID
    import com.bloomberglp.blpapi.Datetime
    import com.bloomberglp.blpapi.Element
    import com.bloomberglp.blpapi.Event
    import com.bloomberglp.blpapi.Message
    import com.bloomberglp.blpapi.MessageIterator
    import com.bloomberglp.blpapi.Request
    import com.bloomberglp.blpapi.Service
    import com.bloomberglp.blpapi.Session
    import com.bloomberglp.blpapi.SessionOptions
    import com.bloomberglp.blpapi.Schema
  end
  
end
