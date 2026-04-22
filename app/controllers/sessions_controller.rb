class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']
    provider = auth.provider.to_s
    uid = auth.uid.to_s
    email = auth.info.email&.downcase
    provider_uid_column = User.provider_uid_column(provider)

    unless provider_uid_column
      redirect_to '/', alert: 'Provider não suportado.'
      return
    end

    user = User.find_by(provider_uid_column => uid)
    user ||= User.find_by(email: email) if email.present?
    user ||= User.new(email: email)

    user.name = auth.info.name if auth.info.name.present?
    user.email ||= email
    user.provider = provider
    user.uid = uid
    user[provider_uid_column] = uid
    user.save!

    session[:user_id] = user.id
    redirect_to '/protected'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to '/', alert: "Erro ao autenticar: #{e.message}"
  end

  def destroy
    session.delete(:user_id)
    redirect_to '/'
  end
end