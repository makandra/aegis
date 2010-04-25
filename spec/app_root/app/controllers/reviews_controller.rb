class ReviewsController < ApplicationController

  permissions :property_reviews

  def show
  end

  def edit
  end

  def update
  end

  def new
  end

  def create
  end

  def destroy
  end

  def index
  end

  private

  def object
    @oject ||= parent_object.reviews.find(params[:id])
  end

  def parent_object
    @parent_object ||= Property.find(params[:id])
  end

end