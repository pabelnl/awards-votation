class HomeController < ApplicationController
  require 'securerandom'
  require 'base64'

  def index
    # Lista de participantes
    @participantes = [
      "Yamil",
      "Yael",
      "Jatna",
      "Gabriela",
      "Pabel",
      "Luis",
      "Pathy",
      "Mitchel",
      "Faniela",
      "Roosvelt",
      "Ruben",
      "Manuel",
      "Pino",
      "Harold",
      "Katherine",
      "Carlos",
      "Anyely",
      "Nicole",
      "Nelson"
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
    return render :template => "voter_mailer/voter_email"
    # error = []
    # if params[:token].present?
    #   if voter = Voter.where(confirmation_token: params[:token]).take
    #     if voter.confirmed is true
    #       error.push("Esta votacion ya fue confirmada.")
    #     else
    #       voter.confirmed = true
    #       voter.save
    #     end
    #   else
    #     error.push("No existe ninguna votacion con ese token de confirmacion.")
    #   end
    # else
    #   error.push("No existe el token de confirmacion en el url.")
    # end
    #
    # if error.count > 0
    #   render :template => "home/error", :locals => {:error => error}
    # end

  end

  def result
    @mmgvoWinner = Voter.select([:mmgvo, Voter.arel_table[:mmgvo].count]).to_a
    @revelacionesWinner = Voter.select([:revelacion, Voter.arel_table[:revelacion].count]).to_a
    @infelicesWinner = Voter.select([:infeliz, Voter.arel_table[:infeliz].count]).to_a

    @votes = Voter.where(confirmed: true)
  end

  private

  def vote_params
    ActionController::Parameters.permit_all_parameters = true
    return params
  end

end
