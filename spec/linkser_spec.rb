require 'spec_helper'
require 'linkser'

describe Linkser do
  it "should be valid" do
    Linkser.should be_a(Module)
  end
end