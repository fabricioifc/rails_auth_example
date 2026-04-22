class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']

    user = User.find_or_create_by(provider: auth.provider, uid: auth.uid) do |u|
      u.name = auth.info.name
      u.email = auth.info.email
    end

    session[:user_id] = user.id
    redirect_to '/protected'
  end

  def destroy
    session.delete(:user_id)
    redirect_to '/'
  end
end