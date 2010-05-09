require File.dirname(__FILE__) + "/spec_helper"

describe Aegis::Sieve do

  before(:each) do
    @role = stub('role', :name => 'user')
    @user = stub('user', :role => @role)
    @context = OpenStruct.new(:user => @user)
  end

  describe 'may? 'do

    it "should use the role's name to find out if the sieve matches" do
      @role.should_receive(:name)
      Aegis::Sieve.new('moderator', true).may?(@context)
    end

    it "should return nil if the sieve doesn't match the role" do
      Aegis::Sieve.new('moderator', true).may?(@context).should be_nil
    end

    it "should return the effect if the sieve matches the role" do
      Aegis::Sieve.new('user', true).may?(@context).should be_true
      Aegis::Sieve.new('user', false).may?(@context).should be_false
    end

    it "should match any role if its role name is set to 'everyone'" do
      Aegis::Sieve.new('everyone', true).may?(@context).should be_true
      Aegis::Sieve.new('everyone', false).may?(@context).should be_false
    end

    context "with a block" do

      it "should return the effect if the block evaluates to true" do
        Aegis::Sieve.new('user', true, lambda { true }).may?(@context).should be_true
        Aegis::Sieve.new('user', false, lambda { true }).may?(@context).should be_false
      end

      it "should invert the effect if the block evaluates to false" do
        Aegis::Sieve.new('user', true, lambda { false }).may?(@context).should be_false
        Aegis::Sieve.new('user', false, lambda { false }).may?(@context).should be_true
      end

    end

  end

end
