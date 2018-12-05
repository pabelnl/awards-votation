class VoterMailer < ApplicationMailer
  default from: "mmgvoawardsofficial@gmail.com"

  def voter_email(voter)
      @voter = voter
      @base_url = request.base_url
      
      if @voter.mmgvo.present?
        attachments.inline["mmgvo.png"] = File.read("#{Rails.root}/public/lib/imgs/profiles/"+@voter.mmgvo.downcase+".png")
      end
      if @voter.revelacion.present?
        attachments.inline["revelacion.png"] = File.read("#{Rails.root}/public/lib/imgs/profiles/"+@voter.revelacion.downcase+".png")
      end
      if @voter.infeliz.present?
        attachments.inline["infeliz.png"] = File.read("#{Rails.root}/public/lib/imgs/profiles/"+@voter.infeliz.downcase+".png")
      end
      if @voter.jugador.present?
        attachments.inline["jugador.png"] = File.read("#{Rails.root}/public/lib/imgs/profiles/"+@voter.jugador.downcase+".png")
      end
      if @voter.nunca.present?
        attachments.inline["nunca.png"] = File.read("#{Rails.root}/public/lib/imgs/profiles/"+@voter.nunca.downcase+".png")
      end
      mail(to: @voter.email, subject: 'MMGVO Awards 2018 vote confirmation')
  end

end
