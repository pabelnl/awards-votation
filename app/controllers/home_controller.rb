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
      "Harold",
      "Jatna",
      "Jhomar",
      "Katherine",
      "Luis",
      "Manuel",
      "Marcos",
      "Max",
      "Mitchel",
      "Nelson",
      "Nicole",
      "Pabel",
      "Pathy",
      "Pino",
      "Roosvelt",
      "Ruben",
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
        @mmgvoWinner = Voter.select([:mmgvo, Arel.star.count]).having(Arel.star.count.gt(1)).group(:mmgvo)
        if not @mmgvoWinner.first.nil?
          @mmgvoWinnerCount = Voter.select(Arel.star.count).where(Voter.arel_table[:mmgvo].eq(@mmgvoWinner.first["mmgvo"])).size
        end

        @revelacionesWinner = Voter.select([:revelacion, Arel.star.count]).having(Arel.star.count.gt(1)).group(:revelacion)
        if not @revelacionesWinner.first.nil?
          @revelacionesWinnerCount = Voter.select(Arel.star.count).where(Voter.arel_table[:revelacion].eq(@revelacionesWinner.first["revelacion"])).size
        end

        @infelicesWinner = Voter.select([:infeliz, Arel.star.count]).having(Arel.star.count.gt(1)).group(:infeliz)
        if not @infelicesWinner.first.nil?
          @infelicesWinnerCount = Voter.select(Arel.star.count).where(Voter.arel_table[:infeliz].eq(@infelicesWinner.first["infeliz"])).size
        end

        @jugadorWinner = Voter.select([:jugador, Arel.star.count]).having(Arel.star.count.gt(1)).group(:infeliz)
        if not @jugadorWinner.first.nil?
          @jugadorWinnerCount = Voter.select(Arel.star.count).where(Voter.arel_table[:jugador].eq(@jugadorWinner.first["jugador"])).size
        end

        @nuncaWinner = Voter.select([:nunca, Arel.star.count]).having(Arel.star.count.gt(1)).group(:nunca)
        if not @nuncaWinner.first.nil?
          @nuncaWinnerCount = Voter.select(Arel.star.count).where(Voter.arel_table[:nunca].eq(@nuncaWinner.first["nunca"])).size
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
