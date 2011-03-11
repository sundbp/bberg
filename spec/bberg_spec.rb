require 'spec_helper'
require 'bberg'

describe Bberg do
  it "should have a VERSION constant" do
    Bberg.const_get('VERSION').should_not be_empty
  end
end
