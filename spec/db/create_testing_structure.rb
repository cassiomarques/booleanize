class CreateTestingStructure < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.boolean :smart
      t.boolean :active
      t.boolean :dumb
    end
  end
    
  def self.down
    drop_table :users
  end
end
