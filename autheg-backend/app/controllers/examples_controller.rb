class ExamplesController < ApplicationController

  def index
    examples = Example.all.select(:id, :name, :colour)
    render json: examples
  end

end
