class ProtectedController < ApplicationController
  before_action :authorize_request
  
  def index
  end

  def csrf_demo
    demo_text = params[:demo_text].to_s.strip
    csrf_token = form_authenticity_token
    csrf_token_valid = valid_authenticity_token?(
      session, 
      params[:authenticity_token]
    )
    if csrf_token_valid
      notice = demo_text.present? ? "POST recebido com CSRF token válido: #{demo_text}" : "POST recebido com CSRF token válido."
      redirect_to '/protected', notice: notice
    else
      notice = demo_text.present? ? "POST recebido com CSRF token inválido: #{demo_text}" : "POST recebido com CSRF token inválido."
      redirect_to '/protected', alert: notice 
    end

  end
end
