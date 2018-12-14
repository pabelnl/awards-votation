class ApplicationController < ActionController::Base
  protect_from_forgery
  attr_accessor :extra_title
  before_action :is_date_today, only: [:index, :vote, :confirm]

  def is_date_today

    time = DateTime.new(2018,12,15,0,0,0)
    errors = []

    if time.today?
      errors.push("Las votaciones ya no estan abiertas.")
      @error = errors
      return render :template => "home/error", :@error => errors
    else
      return true
    end
  end
end
