class AddFingerPrint < ActiveRecord::Migration[8.0]
  def change
    add_column :short_urls, :fingerprint, :string

    add_index :short_urls, :fingerprint, unique: true
  end
end
