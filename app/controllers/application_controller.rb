class ApplicationController < ActionController::Base
  protect_from_forgery
  attr_accessor :extra_title

end