class CreateTags < ActiveRecord::Migration[5.0]
  def change
    create_table :tags do |t|
      t.string :name

      t.timestamps
    end

    create_table :articles_tags, id: false do |t|
    	t.references :article, foreign_key: true
    	t.references :tag,     foreign_key: true
    end
  end
end
