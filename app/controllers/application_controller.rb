class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user_session, :current_user
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end


  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
    
    def require_user
      unless current_user
        redirect_to new_session_session_url, :alert => "You must be logged in to access that page"
        return false
      end
    end

  def require_no_user
    if current_user
      redirect_to root_url, :alert => "You must be logged out to access that page"
      return false
    end
  end

end
