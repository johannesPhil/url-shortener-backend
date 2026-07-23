class CreateIpLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :ip_locations do |t|
      t.string :ip_address, null: false
      t.string :country, null: false
      t.string :city, null: false

      t.timestamps
    end
    add_index :ip_locations, :ip_address, unique: true
  end
end
