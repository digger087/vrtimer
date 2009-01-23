class CreateLists < ActiveRecord::Migration
  def self.up
    create_table :lists do |t|
      t.column :parent_id, :integer
      t.column :lft, :integer
      t.column :rgt, :integer
      t.column :title, :string
      t.column :order, :integer
    end
  end

  def self.down
    drop_table :lists
  end
end
