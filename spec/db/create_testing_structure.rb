class CreateTestingStructure < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.boolean :smart
      t.boolean :active
      t.boolean :dumb
      t.boolean :deleted
    end
    create_table :posts do |t|
      t.boolean :deleted
      t.boolean :rated
    end
  end
    
  def self.down
    drop_table :users
    drop_table :posts
  end
end
