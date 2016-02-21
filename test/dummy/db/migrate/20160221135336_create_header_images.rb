class CreateHeaderImages < ActiveRecord::Migration[5.0]
  def change
    create_table :header_images do |t|
      t.string :url
      t.references :article, foreign_key: true

      t.timestamps
    end
  end
end
