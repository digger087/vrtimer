require 'test_helper'

class TaskTest < ActiveSupport::TestCase

  fixtures :tasks

  def test_truth
    assert true
  end

  # Task should be valid with right attributes
  def test_valid_with_valid_attributes
    task = Task.new(:title => 'Title', :order => 999)
    assert task.valid?
  end

  # Task should not be valid with empty title
  def test_invalid_with_empty_title
    task = task = Task.new(:title => nil, :order => 999)
    assert !task.valid?
  end

  # Task should not be valid with empty order
  def test_invalid_with_empty_order
    task = Task.new(:title => 'Title', :order => nil)
    assert !task.valid?
  end

  # Task should not be valid with non-digit order
  def test_invalid_with_non_digit_order
    task = Task.new(:title => "Title", :order => "abc")
    assert !task.valid?
  end

  # Task should not be valid if added with not unique order
  def test_invalid_with_non_unique_order
    task1 = Task.new(:title => 'Title', :order => 999)
    task1.save
    task2 = Task.new(:title => 'Title', :order => 999)
    assert !task2.valid?
  end

  # Task order should  be successfully updated with new order even if order is not unique,
  # 'cause orders would be recalculated anyway when moving task.
  def test_task_order_updating
    task1 = Task.new(:title => 'Title', :order => 999)
    task1.save
    assert(task1.update_attributes :order => 1)
    assert(task1.order == 1)
  end

def test_task_title_updating
    task1 = Task.new(:title => 'Title', :order => 999)
    task1.save
    assert(task1.update_attributes :title => "New Title")
    assert(task1.title == "New Title")
  end
  

end
