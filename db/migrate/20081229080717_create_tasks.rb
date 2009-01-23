class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.column :title, :string
      t.column :completed_at, :datetime
      t.column :order, :integer
    end
  end

  def self.down
    drop_table :tasks
  end
end
