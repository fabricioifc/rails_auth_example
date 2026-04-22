class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  
  def authorize_request
    unless session[:user_id]
      redirect_to '/', alert: 'Faça login para continuar.'
      return
    end
    @current_user = User.find_by(id: session[:user_id])
    unless @current_user
      session.delete(:user_id)
      redirect_to '/', alert: 'Sessão inválida. Faça login novamente.'
    end
  end
end
