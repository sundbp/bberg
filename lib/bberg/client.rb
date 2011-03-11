require 'date'

require 'bberg/requests'

module Bberg
  class Client
    
    def initialize(host = "localhost", port = 8194)
      @session_options = Bberg::Native::SessionOptions.new
      @session_options.setServerHost("localhost")
      @session_options.setServerPort(8194)
    end
    
    def historical_data_request(identifiers, start_time, end_time, options = {})
      request = Bberg::Requests::HistoricalDataRequest.new(@session_options, identifiers, start_time, end_time, options)
      request.perform_request
    end

    def reference_data_request(identifiers, options)
      request = Bberg::Requests::ReferenceDataRequest.new(@session_options, identifiers, options)
      request.perform_request
    end
    
    def get_holidays_for_calendar(currency, calendar, start_date, end_date)
      overrides = Hash[
        "CALENDAR_START_DATE", start_date,
        "CALENDAR_END_DATE", end_date
      ]
      overrides["SETTLEMENT_CALENDAR_CODE"] = calendar unless calendar.nil?
      options = Hash[ :fields => ["CALENDAR_HOLIDAYS"]]
      options[:overrides] = overrides
      
      response = self.reference_data_request(currency, options)
      result = response[currency]["CALENDAR_HOLIDAYS"].map {|o| o["Holiday Date"]}
      result
    end
    
    ################## PRIVATE #######################

    private
    
    
  end
end