class CreateSysPriceVersions < ActiveRecord::Migration
  def change
    create_table :sys_price_versions do |t|
      t.string :name, null: false
      t.text :func_desc
      t.string :limits
      t.integer :price, default: 0
      t.boolean :opened, default: true
      t.integer :sort, default: 0

      t.timestamps null: false
    end
  end
end
