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
        # Query for the mmgvo winner
        @mmgvoWinner = []
        queryMmgvo = Voter.select("COUNT(mmgvo) as total, mmgvo").where(:confirmed => true).group(:mmgvo).having("COUNT(mmgvo) > 1").order(:mmgvo).map{|p| {:mmgvo => p.mmgvo, :total => p.total} }
        if not queryMmgvo.nil?
          @mmgvoWinner = queryMmgvo.group_by { |x| x[:total] }.max.last
          @mmgvoWinnerCount = @mmgvoWinner.first[:total]
        end
        # Query for the revelacion winner
        @revelacionesWinner = []
        queryRevelacion = Voter.select("COUNT(revelacion) as total, revelacion").where(:confirmed => true).group(:revelacion).having("COUNT(revelacion) > 1").order(:revelacion).reverse_order.map{|p| {:revelacion => p.revelacion, :total => p.total} }
        if not queryRevelacion.nil?
          @revelacionesWinner = queryRevelacion.group_by { |x| x[:total] }.max.last
          @revelacionesWinnerCount = @revelacionesWinner.first[:total]
        end
        # Query for the infeliz winner
        @infelicesWinner = []
        queryInfeliz = Voter.select("COUNT(infeliz) as total, infeliz").where(:confirmed => true).group(:infeliz).having("COUNT(infeliz) > 1").order(:infeliz).map{|p| {:infeliz => p.infeliz, :total => p.total} }
        if not queryInfeliz.nil?
          @infelicesWinner = queryInfeliz.group_by { |x| x[:total] }.max.last
          @infelicesWinnerCount = @infelicesWinner.first[:total]
        end
        # Query for the jugador winner
        @jugadorWinner = []
        queryJugador = Voter.select("COUNT(jugador) as total, jugador").where(:confirmed => true).group(:jugador).having("COUNT(jugador) > 1").order(:jugador).map{|p| {:jugador => p.jugador, :total => p.total} }
        if not queryJugador.nil?
          @jugadorWinner = queryJugador.group_by { |x| x[:total] }.max.last
          @jugadorWinnerCount = @jugadorWinner.first[:total]
        end
        # Query for the nunca puede winner
        @nuncaWinner = []
        queryNunca = Voter.select("COUNT(nunca) as total, nunca").where(:confirmed => true).group(:nunca).having("COUNT(nunca) > 1").order(:nunca).map{|p| {:nunca => p.nunca, :total => p.total} }
        if not queryNunca.nil?
          @nuncaWinner = queryNunca.group_by { |x| x[:total] }.max.last
          @nuncaWinnerCount = @nuncaWinner.first[:total]
        end

        @votes = Voter.where(confirmed: true)
        @unconfirmedVotes = Voter.where(confirmed: false)
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
