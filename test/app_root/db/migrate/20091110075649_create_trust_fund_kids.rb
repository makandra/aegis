class CreateTrustFundKids < ActiveRecord::Migration

  def self.up
    create_table :trust_fund_kids do |t|
      t.string :role_name
      t.integer :account_balance
      t.timestamps
    end
  end

  def self.down
    drop_table :trust_fund_kids
  end
  
end
