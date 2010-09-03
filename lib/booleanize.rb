# = Booleanize plugin
#
# This plugin adds some helper methods to boolean attributes in Active Record models.
# Author: Cassio Marques (cassiommc@gmail.com)
#
# = Description
#
# Creates two instance methods and two scopes for each of the received boolean attributes.
#  
# == Instance methods
#   
#   Creates a attr_name_humanize for each boolean attribute, which returns a specific string for each boolean true or false.
#   Creates a attr_name? method for each boolean attribute.
#
# == Named scopes
#
#   Creates two scopes for esch boolean attribute:
#     scope :attr_name, :conditions => {:attr_name => true}
#     scope :not_attr_name, :conditions => {:attr_name => false}
#
# == How to use it
#
#   The <tt>booleanize</tt> method can receive several parameters. Each parameter can be:
#   * A Symbol
#   * A Hash like {:attr_name => ['str_for_true', 'str_for_false']}
#   * A Array with three elements, like [:attr_name, 'str_for_true', 'str_for_false']
#
#   class User < ActiveRecord::Base
#     booleanize :active, [:smart, "Yes!", "No, very dumb"], :deleted => ["Yes, I'm gone", "No, I'm still here!"]
#   end
#
# You must pay attention to the fact that the Hash parameter must be the last one, otherwise you must enclose it with {...}
#
# You'll have a humanized instance method for each received boolean attribute:
#
#   u = User.new(:acive => true. :smart => false)
#   u.smart_humanize #=> "No, very dumb"
#
#   If you pass a symbol instead of an array, booleanize will use the 'True' default text for boolean true
#   and the 'False' default text for boolean false.
#
#   booleanize :active, [:smart, "Yes", "No"]
#
#   u.active_humanize #=> "True"
#   u.active? #=> true
#
# You'll also get two new scope methods for your model
#
#   active_users = User.active #=> same as scope :active, :conditions => {:active => true}
#   disabled_users = User.not_active #=> same as scope :not_active, :conditions => {:active => false}
#
require 'singleton'

module Booleanize

  class Config
    include Singleton
    
    attr_accessor :default_for_true, :default_for_false
    
    def self.default_strings(options = {})
      error = "Wrong configuration parameters for booleanize: You should pass something like {:true => \"Yes\", :false => \"No\" }"
      raise error unless options.is_a?(Hash) and [:true, :false].all? { |k| options.has_key? k }
      instance.default_for_true = options[:true]
      instance.default_for_false = options[:false]
    end

    protected
    def self.default_for_true; instance.default_for_true rescue nil; end
    def self.default_for_false; instance.default_for_false rescue nil; end
  end

  def booleanize(*params)
    params.each do |param|
      case param
        when Symbol; create_methods_for_symbol(param)
        when Array; create_methods_for_array(param)
        when Hash; create_methods_for_hash(param)
        else raise_error
      end
    end
  end

  private

    def create_true_scope(attr_name)
      scope attr_name, :conditions => { attr_name => true }
    end

    def create_false_scope(attr_name)
      scope :"not_#{attr_name}", :conditions => { attr_name => false }
    end

    def create_humanize_method(attr_name, true_str, false_str)
      true_str = (true_str.nil? ? (Config.default_for_true.nil? ? "True" : Config.default_for_true) : true_str.to_s)
      false_str = (false_str.nil? ? (Config.default_for_false.nil? ? "False" : Config.default_for_false) : false_str.to_s)
      class_eval("def #{attr_name}_humanize; #{attr_name} ? #{true_str.inspect} : #{false_str.inspect}; end")
      
    end

    def create_methods(attr_name, true_str = nil, false_str = nil)
      create_true_scope(attr_name)
      create_false_scope(attr_name)
      create_humanize_method(attr_name, true_str, false_str)
    end

    def create_methods_for_array(array)
      first_is_symbol = array[0].is_a? Symbol
      second_is_string = array[1].is_a? String
      third_is_string = array[2].is_a? String

      if array.length == 3 && first_is_symbol && second_is_string && third_is_string
        create_methods(array[0], array[1], array[2])
      else
        raise_error(array)
      end
    end

    def create_methods_for_symbol(symbol)
      create_methods(symbol)
    end

    def create_methods_for_hash(hash)
      hash.each_pair do |k, v|
        raise_error unless v.is_a? Array and v.length == 2
        create_methods(k, v[0], v[1])
      end
    end

    def raise_error(param)
      raise "You can only pass a three element Array ([:attr_name, 'str_for_true', 'str_for_false']), a Symbol or a Hash (:attr_name => ['str_for_true', 'str_for_false']). You passed #{param.inspect}"
    end

end

ActiveRecord::Base.send(:extend, Booleanize)
