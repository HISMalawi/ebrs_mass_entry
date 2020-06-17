class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :check_user, :except => ['logout', 'login']
  before_filter :set_current_location, :except =>['set_current', 'districts', 'logout', 'login', 'tas', 'villages']
  before_filter :current_location_to_readable, :except =>['set_current', 'districts', 'logout', 'login', 'tas', 'villages']

  def check_user
    if params[:active_tab].present?
      session[:active_tab] = params[:active_tab]
    end

    if session[:user_id].present?
      @cur_user = User.find(session[:user_id]) rescue (redirect_to '/logout' and return)
    else
      redirect_to "/logout"
    end
  end

  def set_current_location
    @cur_location = JSON.parse(File.read("#{Rails.root}/public/current.json")) rescue {}
    if @cur_location.blank?
      redirect_to "/location/set_current"
    end
  end

  def enabled?(groups=[])

    yes = true
    (groups || []).each do |cat|

    end

    yes
  end
  def current_location_to_readable
    cur_location = JSON.parse(File.read("#{Rails.root}/public/current.json")) rescue {}
    @current_location = " Location Not Set"
    case cur_location['type']
    when "DRO"
      @current_location = "#{cur_location['district']} DRO"
    when "Village"
      @current_location = "#{cur_location['village']}, #{cur_location['ta']}, #{cur_location['district']}"
    when "Health Facility"
      @current_location = "#{cur_location['health_facility']}, #{cur_location['district']}"
    else
      "Error: capacity has an invalid value (#{params[:type]})"
    end
  end
end
