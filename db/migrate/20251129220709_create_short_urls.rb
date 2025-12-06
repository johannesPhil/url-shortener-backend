class CreateShortUrls < ActiveRecord::Migration[8.0]
  def change
    create_table :short_urls do |t|
      t.text :original_url, null:false
      t.string :slug, null:false, index:{unique:true}
      t.integer :visits, default: 0, null:false

      t.timestamps
    end
  end
end
