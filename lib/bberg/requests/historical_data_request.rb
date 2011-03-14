require 'bberg/bberg_exception'
require 'bberg/requests/refdata_request_base'

module Bberg
  module Requests
    
    # A class for preforming historical data requets. 
    class HistoricalDataRequest < RefdataRequestBase
    
      DEFAULT_OPTIONS = Hash[
        :fields => ["PX_SETTLE"],
        :frequency => "DAILY"
      ]

      # Create new instance.
      # @param [Bberg::Native::SessionOptions] session_options to specify how to connect session.
      # @param [#each|String] identifiers a list of identifiers for this request
      # @param [Time] start_time start of historical range
      # @param [Time] end_time end of historical range
      # @param [Hash] options_arg specification of what fields or other parameters to use for the request.
      def initialize(session_options, identifiers, start_time, end_time, options_arg = {})
        @session_options = session_options
        
        @identifiers = unless identifiers.respond_to? 'each'
          [identifiers]
        else
          identifiers
        end
        
        @start_time = start_time
        @end_time = end_time
        
        @options = DEFAULT_OPTIONS.merge(options_arg)
      end
      
      # Create a historical data request.
      def create_request
        request = @svc.createRequest("HistoricalDataRequest")
        request.set("startDate", @start_time.strftime("%Y%m%d"))
        request.set("endDate", @end_time.strftime("%Y%m%d"))
        request.set("periodicitySelection", @options[:frequency])
        request.set("returnEids", false)
        @identifiers.each {|identifier| request.append("securities", identifier) }
        @options[:fields].each {|f| request.append("fields", f) }
        @request = request
      end
      
      # Parse event for HistoricalDataResponse.
      # @return [Hash] event parsed into a Hash format.
      def parse_response(event)
        iter = event.messageIterator()
        result = Hash.new
        
        while iter.hasNext()
          
          message = iter.next()
          raise Bberg::BbergException.new("Got a response with incorrect correlation id!") if message.correlationID != @req_id
          msg_type = message.messageType().toString()
          raise Bberg::BbergException.new("Expected message of type HistoricalDataResponse but got #{msg_type}") if msg_type != "HistoricalDataResponse"
          
          field_data = message.getElement("securityData").getElement("fieldData")
          security_name = message.getElement("securityData").getElementAsString("security")
          
          result[security_name] ||= []
          
          (0..(field_data.numValues - 1)).each do |field_num|
            field_values = get_field_values(field_data, field_num)
            result[security_name] << field_values
          end
        end
        result  
      end
          
      ##################### PRIVATE ############################
      
      private
      
      def get_field_values(field_data, field_num)
        element = field_data.getValueAsElement(field_num)
        timestamp = convert_to_rb_time(element.getElementAsDatetime("date"))
        values = Hash.new
        values["date"] = timestamp
        
        @options[:fields].each do |field|
          raise Bberg::BbergException.new("Can't find required field #{field} in response") unless element.hasElement(field)
          field_element = element.getElement(field)
          
          data_type = element.getElement(field).datatype()
          
          values[field] = case data_type.intValue()
          when Bberg::Native::Schema::Datatype::Constants::INT32
            element.getElementAsInt32(field).to_i
          when Bberg::Native::Schema::Datatype::Constants::INT64
            element.getElementAsInt64(field).to_i
          when Bberg::Native::Schema::Datatype::Constants::FLOAT32
            element.getElementAsFloat32(field).to_f
          when  Bberg::Native::Schema::Datatype::Constants::FLOAT64
            element.getElementAsFloat64(field).to_f
          else
            raise Bberg::BbergException.new("Unsupported data type in response: #{data_type.to_s}")
          end
        end
        values
      end
      
    end
    
  end
end
