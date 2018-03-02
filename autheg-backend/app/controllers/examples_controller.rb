class ExamplesController < ApplicationController
  before_action :authenticate_user!

  def index
    examples = Example.all.select(:id, :name, :colour)
    render json: examples
  end

end
