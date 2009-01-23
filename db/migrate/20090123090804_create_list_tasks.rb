class CreateListTasks < ActiveRecord::Migration
  def self.up
    create_table :list_tasks do |t|
    t.column :list_id, :integer
    t.column :task_id, :integer
    end
  end

  def self.down
    drop_table :list_tasks
  end
end
