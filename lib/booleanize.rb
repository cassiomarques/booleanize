# == Booleanize plugin
#   This plugin adds some helper methods to boolean attributes in Active Record models.
# 
# Author: Cassio Marques (cassiommc@gmail.com)
module Booleanize
  def self.included(base)
    base.extend(ClassMethods)
  end
 
  module ClassMethods
    # Creates two instance methods and two named scopes for each of the received boolean attributes.
    #  
    # == Instance methods
    #   
    #   Creates a attr_name_humanize for each boolean attribute, which returns a specific string for each boolean true or false.
    #   Creates a attr_name? method for each boolean attribute.
    #
    # == Named scopes
    #
    #   Creates two named scopes for esch boolean attribute:
    #     named_scope :attr_name, :conditions => {:attr_name => true}
    #     named_scope :not_attr_name, :conditions => {:attr_name => false}
    #
    # == How to use it
    #
    #   The <tt>booleanize</tt> method can receive several parameters. Each parameter can be a symbol or an array of 
    #   three elements, like [:attr_name, 'text for true', 'text for false']
    #
    #   class User < ActiveRecord::Base
    #     booleanize :active, [:smart, "Yes!", "No, very dumb"]
    #   end
    #
    # You'll have 2 new instance methods for each received boolean attribute:
    #
    #   u = User.new(:acive => true. :smart => false)
    #   u.smart_humanize #=> "No, very dumb"
    #   u.smart? #=> false
    #
    #   If you pass a symbol instead of an array, booleanize will use the 'True' default text for boolean true
    #   and the 'False' default text for boolean false.
    #
    #   booleanize :active, [:smart, "Yes", "No"]
    #
    #   u.active_humanize #=> "True"
    #   u.active? #=> true
    #
    # You'll also get two new named_scope methods for your model
    #
    #   active_users = User.active #=> same as named_scope :active, :conditions => {:active => true}
    #   disabled_users = User.not_active #=> same as named_scope :not_active, :conditions => {:active => false}
    #
    def booleanize(*params)   
      params.each do |param|        
        if param.is_a? Array
          first_is_symbol = param[0].is_a? Symbol
          second_is_string = param[1].is_a? String
          third_is_string = param[2].is_a? String
          if param.length == 3 && first_is_symbol && second_is_string && third_is_string
            attr_name = param[0]
            true_str = param[1]
            false_str = param[2]  
          else
            raise_error(param)      
          end
        elsif param.is_a? Symbol
          attr_name = param
          true_str = 'True'
          false_str = 'False'
        else
          raise_error(param)
        end
        class_eval("def #{attr_name}_humanize; #{attr_name} ? '#{true_str}' : '#{false_str}'; end")
        class_eval("def #{attr_name}?; #{attr_name} ? true : false; end")
        eval("self.named_scope :#{attr_name}, :conditions => {:#{attr_name} => true}", get_b)
        eval("self.named_scope :not_#{attr_name}, :conditions => {:#{attr_name} => false}", get_b)
      end
    end
    
    private
    def get_b; binding; end
      
    def raise_error(param)
      raise "You should pass an array with three elements, like [:attr_name, 'text for true', 'text for false'], you passed #{param.inspect}"
    end
  end 
end

ActiveRecord::Base.send(:include, Booleanize)


