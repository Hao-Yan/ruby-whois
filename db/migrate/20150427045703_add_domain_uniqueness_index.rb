class AddDomainUniquenessIndex < ActiveRecord::Migration
  def change
      add_index :domains, :domain, :unique => true
  end
end
