class HomeController < ApplicationController

  require 'securerandom'
  require 'base64'

  def index
    # Lista de participantes
    @participantes = [
      "Angely",
      "Audry",
      "Carlos",
      "Daniela",
      "Faniela",
      "Gabriela",
      "Gladys",
      "Harold",
      "Jatna",
      "Jhomar",
      "Katherine",
      "Luis",
      "Manuel",
      "Marco",
      "Max",
      "Mitchel",
      "Nelson",
      "Nicole",
      "Pabel",
      "Pathy",
      "Pino",
      "Plinio",
      "Roosvelt",
      "Yael",
      "Yamil"
    ]

  end

  def vote

    voter = Voter.new
    error = []
    # Verify params and email format
    if vote_params[:user][:email].present?
      if EmailValidator.valid?(vote_params[:user][:email])
        voter.email = vote_params[:user][:email]
        if _ = Voter.where(email: voter.email).take
          error.push("Este email ya ha sido utilizado para votar.")
        end
      else
        error.push("Formato de Email incorrecto.")
      end
    else
      error.push("No se pudo encontrar el email en los parametros del formulario.")
    end

    if vote_params[:mmgvo].present?
      voter.mmgvo = vote_params[:mmgvo]
    else
      error.push("No se pudo encontrar el candidato para mmgvo en los parametros del formulario.")
    end

    if vote_params[:revelacion].present?
      voter.revelacion = vote_params[:revelacion]
    else
      error.push("No se pudo encontrar el candidato para revelacion en los parametros del formulario.")
    end

    if vote_params[:infeliz].present?
      voter.infeliz = vote_params[:infeliz]
    else
      error.push("No se pudo encontrar el candidato para infeliz en los parametros del formulario.")
    end

    if vote_params[:jugador].present?
      voter.jugador = vote_params[:jugador]
    else
      error.push("No se pudo encontrar el candidato para jugador mas odiado en los parametros del formulario.")
    end

    if vote_params[:nunca].present?
      voter.nunca = vote_params[:nunca]
    else
      error.push("No se pudo encontrar el candidato para el que nunca puede en los parametros del formulario.")
    end

    if error.count > 0
      @error = error
      return render :template => "home/error", :@error => error
    end

    # Generate confirmation token
    random_string = SecureRandom.hex
    voter.confirmation_token = random_string
    voter.confirmed = false
    # Save new voter to db
    voter.save

    # Send confirmation email
    VoterMailer.voter_email(voter).deliver_now
  end

  def confirm
    # return render :template => "voter_mailer/voter_email"
    error = []
    if params[:token].present?
      if voter = Voter.where(confirmation_token: params[:token]).take
        if voter.confirmed == true
          error.push("Esta votacion ya fue confirmada.")
        else
          voter.confirmed = true
          voter.save
        end
      else
        error.push("No existe ninguna votacion con ese token de confirmacion.")
      end
    else
      error.push("No existe el token de confirmacion en el url.")
    end

    if error.count > 0
      @error = error
      render :template => "home/error", :locals => {:error => error}
    end

  end

  def result
    @error = []
    if params[:active].present?
      if params[:active] = "ok"
        @mmgvoWinner = Voter.select("COUNT(mmgvo) as total, mmgvo").group(:mmgvo).having("COUNT(mmgvo) > 1").order(:mmgvo).map{|p| {p.mmgvo => p.total} }
        if not @mmgvoWinner.first.nil?
          @mmgvoWinnerCount = @mmgvoWinner.first.first.second
        end

        @revelacionesWinner = Voter.select("COUNT(revelacion) as total, revelacion").group(:revelacion).having("COUNT(revelacion) > 1").order(:revelacion).reverse_order.map{|p| {p.revelacion => p.total} }
        if not @revelacionesWinner.first.nil?
          @revelacionesWinnerCount = @revelacionesWinner.first.first.second
        end

        @infelicesWinner = Voter.select("COUNT(infeliz) as total, infeliz").group(:infeliz).having("COUNT(infeliz) > 1").order(:infeliz).map{|p| {p.infeliz => p.total} }
        if not @infelicesWinner.first.nil?
          @infelicesWinnerCount = @infelicesWinner.first.first.second
        end

        @jugadorWinner = Voter.select("COUNT(jugador) as total, jugador").group(:jugador).having("COUNT(jugador) > 1").order(:jugador).map{|p| {p.jugador => p.total} }
        if not @jugadorWinner.first.nil?
          @jugadorWinnerCount = @jugadorWinner.first.first.second
        end

        @nuncaWinner = Voter.select("COUNT(nunca) as total, nunca").group(:nunca).having("COUNT(nunca) > 1").order(:nunca).map{|p| {p.nunca => p.total} }
        if not @nuncaWinner.first.nil?
          @nuncaWinnerCount = @nuncaWinner.first.first.second
        end

        @votes = Voter.where(confirmed: true)
      else
        @error.push("No estas autorizado.")
        render :template => "home/error", :locals => {:error => @error}
      end
    else
      @error.push("No estas autorizado.")
      render :template => "home/error", :locals => {:error => @error}
    end

  end

  private

  def vote_params
    ActionController::Parameters.permit_all_parameters = true
    return params
  end

end
