class SlugIsNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null(:short_urls, :slug, true)
  end
end
