class UsersController < ApplicationController
  before_action :authorize_request

  def index
    # ORM (ActiveRecord) para buscar todos os usuários ordenados por nome
    # select * from users order by name;
    @users = User.order(:name)
  end
end
