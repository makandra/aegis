require File.dirname(__FILE__) + '/../spec_helper'

describe ReviewsController do

  before(:each) do
    Property.stub(:find => stub("a property", :reviews => stub("reviews", :find => "a review")))
  end

  it "should grant access in a fully integrated scenario" do
    lambda { get :show, :property_id => '10', :id => '20' }.should_not raise_error
    lambda { get :index, :property_id => '10' }.should_not raise_error
  end

  it "should deny access in a fully integrated scenario" do
    lambda { put :update, :property_id => '10', :id => '20' }.should raise_error(Aegis::AccessDenied)
    lambda { get :new, :property_id => '10' }.should raise_error(Aegis::AccessDenied)
  end

end
