class CreateSoldiers < ActiveRecord::Migration

  def self.up
  
    create_table :soldiers do |t|
      t.string :rank
      t.timestamps
    end
    
  end

  def self.down
    drop_table :soldiers
  end
  
end
