class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :domain
      t.string :create_time
      t.string :updated_time
      t.string :expires_time
      t.string :registrant_org
      t.string :related_email
      t.string :related_country
      t.integer :nameserver_count

      t.timestamps null: false
    end
  end
end
