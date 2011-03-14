require 'date'

require 'bberg/requests'

module Bberg
  
  # Main class for making synchronous bberg data requests.
  class Client
    
    # Create a new instance of Client
    # @param [String] host host running bberg we want to connect to
    # @param [Fixnum] port port to connect to
    def initialize(host = "localhost", port = 8194)
      @session_options = Bberg::Native::SessionOptions.new
      @session_options.setServerHost("localhost")
      @session_options.setServerPort(8194)
    end

    # Perform a historical data request.
    # @param [#each|String] identifiers a list of identifiers for this request
    # @param [Time] start_time start of historical range
    # @param [Time] end_time end of historical range
    # @param [Hash] options_arg specification of what fields or other parameters to use for the request.
    # @return [Hash] result in Hash format.
    def historical_data_request(identifiers, start_time, end_time, options = {})
      request = Bberg::Requests::HistoricalDataRequest.new(@session_options, identifiers, start_time, end_time, options)
      request.perform_request
    end

    # Perform a reference data request.
    # @param [#each|String] identifiers a list of identifiers for this request
    # @param [Hash] options_arg specification of what fields or other parameters to use for the request.
    # @return [Hash] result in Hash format.
    def reference_data_request(identifiers, options)
      request = Bberg::Requests::ReferenceDataRequest.new(@session_options, identifiers, options)
      request.perform_request
    end
    
    # Convencience method to perform a reference data request for holiday calendar data.
    # @param [String] currency which settlement currency to use for calendar.
    # @param [String] calendar name of calendar.
    # @param [Date|Time] start_date when to start calendar from.
    # @param [Date|Time] end_date when to end calendar.
    # @return [Array] an array of Dates.
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