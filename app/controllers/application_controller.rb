class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :session_debug_data

  
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

  def session_debug_data
    user = User.find_by(id: session[:user_id]) if session[:user_id]
    expire_after_seconds = request.session_options[:expire_after]&.to_i

    {
      authenticated: session[:user_id].present? && user.present?,
      session_user_id: session[:user_id],
      user_name: user&.name,
      user_email: user&.email,
      session_cookie_key: Rails.application.config.session_options[:key],
      session_ttl_minutes: expire_after_seconds ? (expire_after_seconds / 60) : nil,
      session_keys: session.to_hash.keys.map(&:to_s).sort,
      request_host: request.host_with_port,
      request_scheme: request.protocol.delete_suffix('://')
    }
  end
end
