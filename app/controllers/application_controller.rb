class ApplicationController < ActionController::Base
  protect_from_forgery
  attr_accessor :extra_title
  before_action :votation_ended?, only: [:index, :vote, :confirm]

  def votation_ended?

    time = DateTime.new(2018,12,14,0,0,0)
    errors = []

    if time.today? || time.past?
      errors.push("Las votaciones ya no estan abiertas.")
      @error = errors
      return render :template => "home/error", :@error => errors
    else
      return true
    end
  end
end
