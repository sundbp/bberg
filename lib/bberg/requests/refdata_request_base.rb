require 'bberg/bberg_exception'

module Bberg
  module Requests
    
    class RefdataRequestBase

      def initialize
        raise Bberg::BbergException.new "Trying to instantiate base class!"
      end
      
      def perform_request()
        @session, @svc, @req_id = create_ref_data_service()
        
        create_request
        
        @session.sendRequest(@request, @req_id)
  
        response = retrieve_response
      
        @session.stop()
        @session = nil
        
        response
      end

      def create_request
        raise Bberg::BbergException.new("Not implemented on base class!")
      end

      def retrieve_response
        not_done = true
        result = Hash.new
        while not_done
          event = @session.nextEvent()
          case event.eventType().intValue()
          when Bberg::Native::Event::EventType::Constants::RESPONSE
            print_response_event(event) if $DEBUG
            event_result = parse_response(event)
            result = hash_merge_concat(result, event_result)
            not_done = false
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
      
      def parse_response(event)
        raise Bberg::BbergException.new("Not implemented in base class!")
      end
      
      ##################### PROTECTED ############################
      
      protected
      
      def create_ref_data_service
        session = Bberg::Native::Session.new(@session_options)
        raise Bberg::BbergException.new("Could not start session!") unless session.start()
        raise Bberg::BbergException.new("Could not open service!") unless session.openService("//blp/refdata")
        request_id = get_correlation_id()
        ref_data_service = session.getService("//blp/refdata")
        [session, ref_data_service, request_id]
      end
      
      def convert_value(value)
        if value.is_a? Date or value.is_a? DateTime or value.is_a? Time
          value.strftime("%Y%m%d")
        else
          value
        end
      end

      def get_correlation_id
        # TODO: we need a mutex protected instance variable of increasing ID's to pass in here
        Bberg::Native::CorrelationID.new(1)
      end
      
      def hash_merge_concat(existing_res, new_res)
        new_res.each do |key, value|
          if existing_res.has_key? key
            existing_res[key] = existing_res[key].concat(value)
          else
            existing_res[key] = value
          end
        end
        existing_res
      end
      
      def convert_to_time(dt)
        hour = dt.hour == 24 ? 0 : dt.hour
        Time.local(dt.year, dt.month, dt.dayOfMonth, hour, dt.minute, dt.second, dt.milliSecond)
      end
      
      def convert_to_date(d)
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
