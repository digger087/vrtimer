class ListsController < ApplicationController

  def index
    @root_list = List.find 1
    @children_lists = @root_list.children
  end

  def new
    
  end

  def create 
    @task = Task.new(params[:task])
    @task.order = Task.count(:all) + 1
    if !@task.save
      errors_on_task = Hash.new
      @task.errors.each do |key, value|
        errors_on_task[key.to_sym] = value
      end
      flash[:errors_on_task] = errors_on_task
    end
    redirect_to root_path
  end

  def show
    @task = Task.find params[:id]
  end

  def edit
    @task = Task.find params[:id]
  end

  def update
    @task = Task.find params[:id]
    if !@task.update_attributes params[:task]
      errors_on_task = Hash.new
      @task.errors.each do |key, value|
        errors_on_task[key.to_sym] = value
      end
      flash[:errors_on_task] = errors_on_task
      redirect_to edit_task_path(@task) and return
    end
    notices = Hash.new
    notices[:updated] = "Task was updated"
    flash[:notices] = notices
    redirect_to task_path(@task)
  end

  def destroy
    @task = Task.find params[:id]

    # Rewriting orders of lower position tasks
    @tasks_to_update = Task.find(:all, :conditions => ["`order` > ? AND id != ? ",
        @task.order, @task.id], :order => "`order` ASC")

    @tasks_to_update.each do |task|
      task.update_attribute(:order, task.order - 1)
    end

    Task.destroy @task
    notices = Hash.new
    notices[:deleted] = "Task was deleted"
    flash[:notices] = notices
    redirect_to root_path
  end

  def change_order
    # ------------- Checking if the order has changed and memorizing
    #                    original value and new value of changed order.
    # ------------- Break when first changed order found from top 
    #                    to ignore the lower ones
    params[:tasks_orders].each do |original,actual|
      if original != actual
        @the_order_has_changed = true
        @original_order = original.to_i
        @order_to_be_set = actual
        break
      end
    end
    # ------------

    if @the_order_has_changed 
      @changed_task = Task.find_by_order @original_order
      if @changed_task.update_attributes(:order => @order_to_be_set)
        @order_to_be_set = @order_to_be_set.to_i
        
        ## -------------- Moving task down --------------
        if @tasks_to_update = Task.find(:all, :conditions => ["`order` >= ? AND `order` <= ? AND id != ? ",
              @original_order, @order_to_be_set, @changed_task.id], :order => "`order` ASC")

          @we_mowing_task_down = true
          @tasks_to_update.each do |task|
            task.update_attribute(:order, task.order - 1)
          end
        end

        ## ------------ Moving task up -------------
        if not @we_moving_task_down
          @tasks_to_update = Task.find(:all, :conditions => ["`order` >= ? AND id != ? ",
              @order_to_be_set, @changed_task.id], :order => "`order` ASC")

          @order = @order_to_be_set
          @tasks_to_update.each do |task|
            task.update_attribute(:order, @order + 1)
            @order+= 1
          end
        end
      else
        errors_on_task = Hash.new
        @changed_task.errors.each do |key, value|
          errors_on_task[key.to_sym] = value
        end
        flash[:errors_on_task] = errors_on_task
      end
    else
      errors_on_order = Hash.new
      errors_on_order[:no_order] = "No order has been changed"
      flash[:errors_on_changing_order] = errors_on_order
    end
    redirect_to root_path

  end

end
