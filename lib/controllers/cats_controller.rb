require_relative '../sql_object'
require_relative '../controller_base'

class Cat < SQLObject
  finalize!
end

class CatsController < ControllerBase
  def index
    @cats = Cat.all
    render :index
  end

  def new
    @cat = Cat.new

    render :new
  end

  def create
    @cat = Cat.new(cat_params);
    @cat.owner_id = current_user

    if @cat.save
      redirect_to cat_url(@cat)
    else
      flash.now[:errors] = @cat.errors.full_messages
    end
  end

  private

    def cat_params
      params.require(:cat).permit(:name)
    end
end
