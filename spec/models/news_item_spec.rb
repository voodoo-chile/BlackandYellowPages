require File.dirname(__FILE__) + '/../spec_helper'

describe NewsItem do
  it "should be valid" do
    NewsItem.new.should be_valid
  end
end
