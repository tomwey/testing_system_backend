class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :data_file_name
      t.string :data_content_type
      t.integer :data_file_size
      t.references :owner, polymorphic: true, index: true
      t.integer :width
      t.integer :height

      t.timestamps null: false
    end
  end
end
