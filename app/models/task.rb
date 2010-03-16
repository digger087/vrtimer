class Task < ActiveRecord::Base
  has_many :time_records

  validates_presence_of :title, :message => "Title can't be blank"
  validates_presence_of :order
  validates_uniqueness_of :order, :on => :create
  validates_numericality_of :order, :message => "Order should be a number"

end
