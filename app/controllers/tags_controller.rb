class TagsController < ApplicationController
  def create
    @tags = Tags.new(tag_params)
    
  end
end
