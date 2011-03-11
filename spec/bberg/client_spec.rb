require 'spec_helper'
require 'bberg'

describe Bberg::Client do
  before(:each) do
    @client = Bberg::Client.new
  end
  
  it "should handle historical data request for one security" do
    securities = ["CLF1 Comdty"]
    start_time = Date.new(2010,12,1)
    end_time = Date.new(2010,12,3)
    data = @client.historical_data_request(securities,  start_time, end_time)
    data.has_key?(securities.first).should be_true
    data[securities.first].size.should == 3
    data[securities.first][0]["date"].should == Date.new(2010,12,1).to_time
    data[securities.first][0]["PX_SETTLE"].should == 86.75
    data[securities.first][1]["date"].should == Date.new(2010,12,2).to_time
    data[securities.first][1]["PX_SETTLE"].should == 88.00
    data[securities.first][2]["date"].should == Date.new(2010,12,3).to_time
    data[securities.first][2]["PX_SETTLE"].should == 89.19
  end
  
  it "should handle historical data request with one security not given as array" do
    security = "CLF1 Comdty"
    start_time = Date.new(2010,12,1)
    end_time = Date.new(2010,12,3)
    data = @client.historical_data_request(security, start_time, end_time)
    data.has_key?(security).should be_true
    data[security].size.should == 3
  end
  
  it "should handle historical data request for multiple securities" do
    securities = ["CLF1 Comdty", "CLG1 Comdty"]
    start_time = Date.new(2010,12,1)
    end_time = Date.new(2010,12,3)
    data = @client.historical_data_request(securities,  start_time, end_time)
    
    data.has_key?(securities.first).should be_true
    data.has_key?(securities.last).should be_true
    
    data[securities.first].size.should == 3
    data[securities.first][0]["date"].should == Date.new(2010,12,1).to_time
    data[securities.first][0]["PX_SETTLE"].should == 86.75
    data[securities.first][1]["date"].should == Date.new(2010,12,2).to_time
    data[securities.first][1]["PX_SETTLE"].should == 88.00
    data[securities.first][2]["date"].should == Date.new(2010,12,3).to_time
    data[securities.first][2]["PX_SETTLE"].should == 89.19
    
    data[securities.last].size.should == 3
    data[securities.last][0]["date"].should == Date.new(2010,12,1).to_time
    data[securities.last][0]["PX_SETTLE"].should == 87.25
    data[securities.last][1]["date"].should == Date.new(2010,12,2).to_time
    data[securities.last][1]["PX_SETTLE"].should == 88.42
    data[securities.last][2]["date"].should == Date.new(2010,12,3).to_time
    data[securities.last][2]["PX_SETTLE"].should == 89.59
  end
  
  it "should handle historical data request for multiple fields" do
    security = "CLF1 Comdty"
    start_time = Date.new(2010,12,1)
    end_time = Date.new(2010,12,3)
    data = @client.historical_data_request(security, start_time, end_time, :fields => ["PX_OPEN", "PX_HIGH"])
    data.has_key?(security).should be_true
    data[security].size.should == 3
    
    data[security][0]["date"].should == Date.new(2010,12,1).to_time
    data[security][0]["PX_OPEN"].should == 83.66
    data[security][0]["PX_HIGH"].should == 86.95
    data[security][1]["date"].should == Date.new(2010,12,2).to_time
    data[security][1]["PX_OPEN"].should == 86.80
    data[security][1]["PX_HIGH"].should == 88.13
    data[security][2]["date"].should == Date.new(2010,12,3).to_time
    data[security][2]["PX_OPEN"].should == 87.94
    data[security][2]["PX_HIGH"].should == 89.49
  end
  
  it "should get holiday calendar reference data correctly (tests overrides)" do
    start_date = Date.new(2010, 1, 1)
    end_date = Date.new(2010, 12, 31)
    holidays = @client.get_holidays_for_calendar("USD Curncy", "NM", start_date, end_date)
    
    known_holidays = [
      Date.new(2010,1,1),
      Date.new(2010,1,18),
      Date.new(2010,2,15),
      Date.new(2010,4,2),
      Date.new(2010,5,31),
      Date.new(2010,7,5),
      Date.new(2010,9,6),
      Date.new(2010,11,25),
      Date.new(2010,12,24),
    ]
    
    holidays.size.should == known_holidays.size
    holidays.each_with_index {|d,i| d.should == known_holidays[i] }
  end
  
end
