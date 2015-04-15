class Users::ReviewsController < ApplicationController

  def new
    @review = UserReview.new
  end

end
