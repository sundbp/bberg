require 'bberg/bberg_exception'

module Bberg
  
  # Module containing classes for the various bberg requests that can be made
  module Requests

    # Mixin for reference data requests
    # 
    # This relies on particular requests implementing #create_request and
    # #parse_response
    module RefdataRequest

      # Perform a synchronous reference data request
      # 
      # Calls (#create_request) to create the request object to send.
      # Blocks while waiting for the response.
      #
      # @return [Hash] A parsed response in the form of a Hash
      def perform_request
        @session, @svc, @req_id = create_ref_data_service()
        
        create_request
        
        @session.sendRequest(@request, @req_id)
  
        response = retrieve_response
      
        @session.stop()
        @session = nil
        
        response
      end

      # Retrieve response for this request
      #
      # Will retrieve events from the request's session until an event of type REPONSE is found.
      # For each event (partial or not) it will callse (#parse_response) and merge the hash
      # returned into a cummulitative result.
      # 
      # Note: if you set the $DEBUG flag the unparsed event will be printed on STDOUT.
      #
      # @return [Hash] A parsed response in the form of a Hash
      def retrieve_response
        done = false
        result = Hash.new
        until done
          event = @session.nextEvent()
          case event.eventType().intValue()
          when Bberg::Native::Event::EventType::Constants::RESPONSE
            print_response_event(event) if $DEBUG
            event_result = parse_response(event)
            result = hash_merge_concat(result, event_result)
            done = true
          when Bberg::Native::Event::EventType::Constants::PARTIAL_RESPONSE
            print_response_event(event) if $DEBUG
            event_result = parse_response(event)
            result = hash_merge_concat(result, event_result)
          else
            print_other_event(event) if $DEBUG
          end
        end
        result
      end
      
      ##################### PROTECTED ############################
      
      private
      
      # Create a reference data service
      #
      # This both creates and starts a session, and opens a refdata service.
      #
      # @return [Bberg::Native::Session, Object, Fixnum] session, service and request ID
      def create_ref_data_service
        session = Bberg::Native::Session.new(@session_options)
        raise Bberg::BbergException.new("Could not start session!") unless session.start()
        raise Bberg::BbergException.new("Could not open service!") unless session.openService("//blp/refdata")
        request_id = get_correlation_id()
        ref_data_service = session.getService("//blp/refdata")
        [session, ref_data_service, request_id]
      end
      
      # Get correlation ID
      #
      # NOTE: this needs to be updated so we have increasing unique IDs here.
      #
      # @return [Fixnum] correlation ID
      def get_correlation_id
        # TODO: we need a mutex protected instance variable of increasing ID's to pass in here
        Bberg::Native::CorrelationID.new(1)
      end
      
      # Utility method to merge and concatenate two Hashes
      #
      # This is useful for creating a cummulitative Hash result when reply consists of several events.
      #
      # @param [Hash] existing_hash what we have so far
      # @param [Hash] new_hash partial result to add
      # @return [Hash] merged and concatenated result
      def hash_merge_concat(existing_hash, new_hash)
        new_hash.each do |key, value|
          if existing_hash.has_key? key
            existing_hash[key] = existing_hash[key].concat(value)
          else
            existing_hash[key] = value
          end
        end
        existing_hash
      end
      
      # Utility method to convert a ruby values to their bberg format
      # 
      # So far only time like types are affected.
      #
      # @return a more ruby friendly conversion of the original value
      def convert_value_to_bberg(value)
        if value.is_a? Date or value.is_a? DateTime or value.is_a? Time
          value.strftime("%Y%m%d")
        else
          value
        end
      end
      
      # Convert a Java::ComBloomberglpBlpapi::Datetime to a ruby Time
      #
      # @return [Time] value as Time
      def convert_to_rb_time(dt)
        hour = dt.hour == 24 ? 0 : dt.hour
        Time.local(dt.year, dt.month, dt.dayOfMonth, hour, dt.minute, dt.second, dt.milliSecond)
      end
      
      # Convert a Java::ComBloomberglpBlpapi::Datetime to a ruby Date
      #
      # @return [Date] value as Date
      def convert_to_rb_date(d)
        Date.new(d.year, d.month, d.dayOfMonth)
      end
            
      def print_response_event(event)
        iter = event.messageIterator()
        while iter.hasNext()
          message = iter.next()
          puts "correlationID=" + message.correlationID().to_s
          puts "messageType =" + message.messageType().toString()
          puts message.toString()
        end
      end
      
      def print_other_event(event)
        puts "EventType=" + event.eventType().toString()
        iter = event.messageIterator()
        while iter.hasNext()
          message = iter.next()
          puts "correlationID=" + message.correlationID().to_s
          puts "messageType =" + message.messageType().toString()
          puts message.toString()
          if Bberg::Native::Event::EventType::Constants::SESSION_STATUS == event.eventType().intValue() and
            "SessionStopped" == message.messageType().toString()
            puts "Terminating: " + message.messageType()
            exit
          end
        end
      end
      
    end
  end
end
