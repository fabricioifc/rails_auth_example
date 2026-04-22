class ProtectedController < ApplicationController
  before_action :authorize_request
  
  def index
  end
end
