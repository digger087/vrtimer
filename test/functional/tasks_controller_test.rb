require 'test_helper'

class TasksControllerTest < ActionController::TestCase

  def test_truth
    assert true
  end

  def setup
    @controller = TasksController.new
    @request = ActionController::TestRequest.new
    @respond = ActionController::TestResponse.new
  end

  def test_index_action
    get :index
    assert_response :success
    assert_template 'index'
  end

  def test_creation_of_task_with_valid_attributes
    tasks_count_before_creation = Task.count :all
    post :create, :task => {'title' => 'Task'}
    assert((Task.count :all) == (tasks_count_before_creation + 1))
    assert_redirected_to :action => "index"
  end

  def test_protection_from_creation_of_task_with_invalid_attributes
    tasks_count_before_creation = Task.count :all
    post :create, :task => {'title' => nil}
    assert((Task.count :all) == (tasks_count_before_creation))
    assert(flash[:errors_on_task][:title] == "Title can't be blank")
    assert_redirected_to :action => "index"
  end

  def test_detection_of_changed_order_in_change_order_action_if_the_order_was_changed
    post :change_order, :tasks_orders=>{"1"=>"2", "2"=>"2", "3"=>"3", "4"=>"4", "5"=>"5"}
    assert(assigns(:the_order_has_changed) == true)
  end

  def test_detection_of_changed_order_in_change_order_action_if_the_order_was_not_changed
    post :change_order, :tasks_orders=>{"1"=>"1", "2"=>"2", "3"=>"3", "4"=>"4", "5"=>"5"}
    assert(assigns(:the_order_has_changed) == nil)
  end

  def test_change_order_action_with_no_order_changed_by_user
    post :change_order, :tasks_orders=>{"1"=>"1", "2"=>"2", "3"=>"3", "4"=>"4", "5"=>"5"}
    assert(flash[:errors_on_changing_order][:no_order] == "No order has been changed")
    assert_redirected_to :action => "index"
  end

  def test_change_order_action_with_invalid_order
    post :change_order, :tasks_orders=>{"1"=>"a", "2"=>"2", "3"=>"3", "4"=>"4", "5"=>"5"}
    assert(flash[:errors_on_task][:order] == "Order should be a numer")
    assert_redirected_to :action => "index"
  end

  def test_change_task_order_if_moving_task_from_top_to_any_lower_position
    post :change_order, :tasks_orders=>{"1"=>"3", "2"=>"2", "3"=>"3", "4"=>"4", "5"=>"5"}
    tasks = Task.find :all, :order => "id ASC"
    tasks.unshift nil
    assert(tasks[2].order == 1)
    assert(tasks[3].order == 2)
    assert(tasks[1].order == 3)
    assert(tasks[4].order == 4)
    assert(tasks[5].order == 5)
    assert_redirected_to :action => "index"
  end

  def test_change_task_order_if_moving_task_down
    post :change_order, :tasks_orders=>{"1"=>"1", "2"=>"4", "3"=>"3", "4"=>"4", "5"=>"5"}
    tasks = Task.find :all, :order => "id ASC"
    tasks.unshift nil
    assert(tasks[1].order == 1)
    assert(tasks[3].order == 2)
    assert(tasks[4].order == 3)
    assert(tasks[2].order == 4)
    assert(tasks[5].order == 5)
    assert_redirected_to :action => "index"
  end

  def test_change_task_order_if_moving_task_from_bottom_to_any_higher_position
    post :change_order, :tasks_orders=>{"1"=>"1", "2"=>"2", "3"=>"3", "4"=>"4", "5"=>"2"}
    tasks = Task.find :all, :order => "id ASC"
    tasks.unshift nil
    assert(tasks[1].order == 1)
    assert(tasks[5].order == 2)
    assert(tasks[2].order == 3)
    assert(tasks[3].order == 4)
    assert(tasks[4].order == 5)
    assert_redirected_to :action => "index"
  end

  def test_change_task_order_if_moving_task_up
    post :change_order, :tasks_orders=>{"1"=>"1", "2"=>"2", "3"=>"3", "4"=>"2", "5"=>"5"}
    tasks = Task.find :all, :order => "id ASC"
    tasks.unshift nil
    assert(tasks[1].order == 1)
    assert(tasks[4].order == 2)
    assert(tasks[2].order == 3)
    assert(tasks[3].order == 4)
    assert(tasks[5].order == 5)
    assert_redirected_to :action => "index"
  end

  def test_show_action
    get :show, :id => 1
    assert_response :success
    assert_template 'show'
  end

  def test_edit_action
    get :edit, :id => 1
    assert_response :success
    assert_template 'edit'
  end

  def test_updating_task_title
    post :update, :id => 1, :task => {"title" => "One"}
    task = Task.find 1
    assert(task.title == "One")
    assert(flash[:notices][:updated] == "Task was updated")
    assert_redirected_to :action => "show"
  end

def test_updating_task_title_with_empty_title
    post :update, :id => 1, :task => {"title" => nil}
    assert(flash[:errors_on_task][:title] == "Title can't be blank")
    assert_redirected_to :action => "edit", :id => 1
  end

  def test_deleting_task
    tasks_count_before_creation = Task.count :all
    post :destroy, :id => 1
    assert((Task.count :all) == (tasks_count_before_creation - 1))
    assert_raise(ActiveRecord::RecordNotFound) {Task.find 1}
    assert(flash[:notices][:deleted] == "Task was deleted")
    assert_redirected_to :action => "index"
  end

  def test_deleting_task_and_rewriting_lower_position_orders
    tasks_count_before_creation = Task.count :all
    post :destroy, :id => 1
    assert((Task.count :all) == (tasks_count_before_creation - 1))
    assert_raise(ActiveRecord::RecordNotFound) {Task.find 1}
    tasks = Task.find :all, :order => "id ASC"
    tasks.unshift nil
    assert(tasks[1].id == 2)
    assert(tasks[2].id == 3)
    assert(tasks[3].id == 4)
    assert(tasks[4].id == 5)
    assert(flash[:notices][:deleted] == "Task was deleted")
    assert_redirected_to :action => "index"
  end


end
