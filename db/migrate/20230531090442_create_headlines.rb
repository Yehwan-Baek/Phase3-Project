class CreateHeadlines < ActiveRecord::Migration[6.1]
  def change
    create_table :headlines do |t|
      t.integer :user_id
      t.string :title
      t.string :description
      t.string :url
    end
  end
end
