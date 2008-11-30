require 'rubygems'
require 'spec'
require 'active_record'
require File.dirname(__FILE__) + "/../lib/booleanize"

ActiveRecord::Base.establish_connection(:adapter=>"sqlite3", :database => ":memory:")
require File.dirname(__FILE__) + "/db/create_testing_structure"

CreateTestingStructure.migrate(:up)

class User < ActiveRecord::Base
  booleanize [:dumb, "Dumb as hell!", "No, this is a smart one!"], :active, [:smart, "Yes!", "No, very dumb"]
end

describe "booleanize" do  
  def smart_user
    User.new(:name => "Smart Dude", :active => true, :dumb => false, :smart => true)
  end
  
  def dumb_user
    User.new(:name => "Dumb Dude", :active => true, :dumb => true, :smart => false)
  end  
  
  it "should raise an exception if any of the attributes is not a Symbol or a three elements array" do
    lambda do
      class Bla < ActiveRecord::Base
        booleanize "bla"
      end
    end.should raise_error
  end
  
  it "should raise an exception if it receives an array but it's not in the format [:attr_name, 'string for true', 'string for false']" do
    lambda do
      class Bla < ActiveRecord::Base
        booleanize [:bla]
      end.should raise_error
    end
    lambda do
      class Bla < ActiveRecord::Base
        booleanize [:bla, 'Yes!']
      end
    end.should raise_error
    lambda do
      class Bla < ActiveRecord::Base
        booleanize [:bla, 'Yes!', :no]
      end
    end.should raise_error    
  end
  
  
  describe "creating boolean_attr_name? method" do
    it "should respond to a boolean_attr_name? for each received attribute" do
      u = smart_user
      [:active?, :dumb?, :smart?].each {|m| u.should respond_to(m)}
    end
    
    it "should return true if the attribute's value is true'" do
      smart_user.should be_smart
      smart_user.should_not be_dumb
    end
    
    it "should return false if the attribute's value is false" do
      dumb_user.should be_dumb
      dumb_user.should_not be_smart
    end
    
    it "should return the new boolean value when a new value is assigned to the attribute" do
      u = smart_user
      u.active = false
      u.should_not be_active
    end
    
    it "should return false is the attribute is nil" do
      u = smart_user
      u.active = nil
      u.active?.should == false
    end
  end
  
  describe "creating boolean_attr_name_humanize method" do
    describe "when a symbol is passed" do
      it "should respond to a boolean_attr_name_humanize method for each received attribute" do
        u = dumb_user 
        [:active_humanize, :dumb_humanize, :smart_humanize].each {|m| u.should respond_to(m)}
      end
    end
    
    describe "when an array is passed" do
      it "should return the specified string for true" do
        smart_user.smart_humanize.should eql("Yes!")
      end
      
      it "should return the specified string for false" do
        dumb_user.smart_humanize.should eql("No, very dumb")
      end
      
      it "should return the string for false when the attribute is nil" do
        u = dumb_user
        u.smart = nil
        u.smart_humanize.should == "No, very dumb"
      end
    end
    
    describe "when a symbol is passed" do
      it "should return the default string for true" do
        smart_user.active_humanize.should eql("True")
      end
      
      it "should return the default string for false" do
        u = smart_user
        u.active = false
        u.active_humanize.should eql("False")
      end
      
      it "should return the string for false when the attribute is nil" do
        u = smart_user
        u.active = false
        u.active_humanize.should eql("False")
      end
    end
  end 
  
  describe "creating named_scopes" do
    before do
      3.times {|i| smart_user.save!; dumb_user.save! }            
    end
    
    after do
      User.delete_all
    end
    
    it "should have a named scope that returns all the objects for which the boolean attribute is true" do
      User.smart.should have(3).items
      User.active.should have(6).items
    end
    
    it "should have a named scope that returns all the objects for which the boolean attribute is false" do
      User.not_smart.should have(3).items
      User.not_active.should be_empty
    end
  end 
end


