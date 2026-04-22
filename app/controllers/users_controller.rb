class UsersController < ApplicationController
  before_action :authorize_request

  def index
    @users = User.order(:name)
  end
end
