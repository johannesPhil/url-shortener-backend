class CreateAnalytics < ActiveRecord::Migration[8.0]
  def change
    create_table :analytics do |t|
      t.references :short_url, null: false, foreign_key: true, index: false
      # t.integer :visits, null: false
      t.string :ip_address, null: false
      t.text :user_agent, null: false
      t.string :city
      t.string :country
      t.datetime :visited_at, null: false
      # TODO: Handle the default value for visited_at in the controller

      t.timestamps
    end

    add_index :analytics, [ :short_url_id, :visited_at ]
  end
end
