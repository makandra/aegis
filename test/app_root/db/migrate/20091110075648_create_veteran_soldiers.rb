class CreateVeteranSoldiers < ActiveRecord::Migration

  def self.up
    create_table :veteran_soldiers do |t|
      t.string :rank
      t.timestamps
    end
  end

  def self.down
    drop_table :veteran_soldiers
  end
  
end
