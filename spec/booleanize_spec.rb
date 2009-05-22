require 'rubygems'
require 'spec'
require 'active_record'
require File.dirname(__FILE__) + "/../lib/booleanize"

ActiveRecord::Base.establish_connection(:adapter=>"sqlite3", :database => ":memory:")
require File.dirname(__FILE__) + "/db/create_testing_structure"

CreateTestingStructure.migrate(:up)

class User < ActiveRecord::Base
  booleanize [:dumb, "Dumb as hell!", "No, this is a smart one!"], :active, [:smart, "Yes!", "No, very dumb"], :deleted => ["Yes, I'm gone", "No, I'm still here!"]
end

class Post < ActiveRecord::Base
  booleanize :deleted => ["Yes", "No"], :rated => ["Yes", "No"]
end

describe "booleanize" do  
  def smart_user
    User.new(:name => "Smart Dude", :active => true, :dumb => false, :smart => true, :deleted => false)
  end
  
  def dumb_user
    User.new(:name => "Dumb Dude", :active => true, :dumb => true, :smart => false, :deleted => false)
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
  
  it "should raise an exception if it receives a hash but it's not in the format :attr_name => ['str_for_true', 'str_for_false']" do
    lambda do
      class Bla < ActiveRecord::Base
        booleanize :attr_nam => []
      end.should raise_error
    end
    lambda do
      class Bla < ActiveRecord::Base
        booleanize :attr_name => ['str_for_true']
      end
    end.should raise_error
    lambda do
      class Bla < ActiveRecord::Base
        booleanize :attr_name => ['bla', 'ble', 'bli']
      end.should raise_error
    end
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
    
    describe "when a hash is passed" do
      it "should return the specified string for true" do
        u = smart_user
        u.deleted = true
        u.deleted_humanize.should eql("Yes, I'm gone")
      end
      
      it "should return the specified string for false" do
        smart_user.deleted_humanize.should eql("No, I'm still here!") 
      end
      
      it "should return the string for false when the attribute is nil" do
        u = smart_user
        u.deleted = nil
        u.deleted_humanize.should eql("No, I'm still here!")
      end
      
      it "should respond to attr_name?" do
        smart_user.should respond_to(:deleted)
      end
      
      describe "with more than on key/value pair" do
        it "should create a 'humanize' method for each key" do
          p = Post.new(:rated => true, :deleted => false)
          p.rated_humanize.should eql("Yes")
          p.deleted_humanize.should eql("No")
        end
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
    
    it "should have a named scope that returns all the objects for which a boolean attribute passed as a hash is true" do
      User.deleted.should be_empty
    end
    
    it "should have a named scope that returns all the objects for which a boolean attribute passed as a hash is false" do
      User.not_deleted.should have(6).items
    end
  end 

  describe "with global configuration" do
    before do
      Booleanize::Config.default_strings :true => "Oh yes!", :false => "Nooo"
      class User
        booleanize :active
        booleanize :smart => ["Too smart", "Duh!"]
      end
    end
    
    it "should use the globally defined string for true" do
      User.create(:active => true).active_humanize.should == "Oh yes!"
    end

    it "should use the globally defined string for false" do
      User.create(:active => false).active_humanize.should == "Nooo"
    end

    it "should use the string for yes specified in the class definition" do
      User.create(:smart => true).smart_humanize.should == "Too smart"
    end

    it "should use the string for no specified in the class definition" do
      User.create(:smart => false).smart_humanize.should == "Duh!"
    end

    it "should raise an exception if the config parameters are not inside a two pairs hash" do
      ["hello", {:bla => :foo}, ["bla", "ble"]].each do |params|
        lambda { Booleanize::Config.default_strings params }.should raise_error
      end
    end
  end
end


