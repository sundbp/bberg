require 'date'
require 'bberg/bberg_exception'
require 'bberg/requests/refdata_request'

module Bberg
  module Requests
    
    # A class for preforming reference data requets
    class ReferenceDataRequest
      include RefdataRequest
    
      # Defaults for reference data requests
      DEFAULT_OPTIONS = Hash[
        :fields => ["PX_SETTLE"],
        :useUTCTime => true,
        :returnEids => false
      ]

      # Create new instance
      #
      # @param [Bberg::Native::SessionOptions] session_options to specify how to connect session
      # @param [#each|String] identifiers a list of identifiers for this request
      # @param [Hash] options_arg specification of what fields or other parameters to use for the request
      def initialize(session_options, identifiers, options_arg = {})
        @session_options = session_options
        
        @identifiers = unless identifiers.respond_to? 'each'
          [identifiers]
        else
          identifiers
        end
        
        @options = DEFAULT_OPTIONS.merge(options_arg)
      end

      # Create a reference data request
      # 
      # @return A bberg request object
      def create_request
        request = @svc.createRequest("ReferenceDataRequest")

        @identifiers.each {|identifier| request.append("securities", identifier) }
        
        @options.each do |key, value|
          next if key == :fields or key == :overrides
          request.set(key.to_s, convert_value_to_bberg(value))
        end
        
        @options[:fields].each {|f| request.append("fields", f) }
        
        overrides = request.getElement("overrides")
        @options[:overrides].each do |field_id, value|
          new_override = overrides.appendElement()
          new_override.setElement("fieldId", field_id.to_s)
          new_override.setElement("value", convert_value_to_bberg(value))
        end
        @request = request
      end
      
      # Parse event for ReferenceDataResponse
      #
      # @return [Hash] event parsed into a Hash format
      def parse_response(event)
        iter = event.messageIterator()
        result = Hash.new
        
        while iter.hasNext()
          
          message = iter.next()
          raise Bberg::BbergException.new("Got a response with incorrect correlation id!") if message.correlationID != @req_id
          msg_type = message.messageType().toString()
          raise Bberg::BbergException.new("Expected message of type ReferenceDataResponse but got #{msg_type}") if msg_type != "ReferenceDataResponse"
          
          security_data_array = message.getElement("securityData")
          (0..(security_data_array.numValues - 1)).each do |sec_num|
            security_data = security_data_array.getValueAsElement(sec_num)
            security_name = security_data.getElementAsString("security")
            field_data = security_data.getElement("fieldData")

            result[security_name] ||= Hash.new
            
            (0..(field_data.numElements - 1)).each do |field_num|
              field_element = field_data.getElement(field_num)
              values = if field_element.isArray
                process_array_type(field_element)
              else
                get_element_values(field_data, field_num)
              end
              result[security_name][field_element.name.toString] = values
            end
          end
        end
        result
      end
      
      ##################### PRIVATE ############################
      
      private
      
      def process_array_type(element)
        result = []
        (0..(element.numValues - 1)).each do |num|
          sub_element = element.getValueAsElement(num)
          values = if sub_element.isArray
            process_array_type(sub_element)
          else
            get_element_values(sub_element)
          end
          result << values
        end
        result
      end

      def get_element_values(sub_element)
        values = Hash.new
        iter = sub_element.elementIterator()
        while iter.hasNext()
          e = iter.next()
          values[e.name.toString] = case e.datatype.intValue()
          when Bberg::Native::Schema::Datatype::Constants::INT32
            e.getValueAsInt32().to_i
          when Bberg::Native::Schema::Datatype::Constants::INT64
            e.getValueAsInt64().to_i
          when Bberg::Native::Schema::Datatype::Constants::FLOAT32
            e.getValueAsFloat32().to_f
          when  Bberg::Native::Schema::Datatype::Constants::FLOAT64
            e.getValueAsFloat64().to_f
          when Bberg::Native::Schema::Datatype::Constants::DATE
            convert_to_rb_date(e.getValueAsDate())
          else
            raise Bberg::BbergException.new("Unsupported data type in response: #{e.datatype.to_s}")
          end
        end
        values
      end
      
    end
    
  end
end
