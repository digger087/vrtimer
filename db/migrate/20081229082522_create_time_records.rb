class CreateTimeRecords < ActiveRecord::Migration
  def self.up
    create_table :time_records do |t|
      t.column :task_id, :integer
      t.column :starttime, :datetime
      t.column :endtime, :datetime
    end
  end

  def self.down
    drop_table :time_records
  end
end
