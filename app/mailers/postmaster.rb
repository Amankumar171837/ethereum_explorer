# frozen_string_literal: true

class Postmaster < ApplicationMailer
  layout 'mailer'

  def process_payload(params)
    @record          = params[:record]
    @changes         = params[:changes]
    @user            = params[:user]
    @logo            = params[:logo]
    @peer_market_url = params[:peer_market_url]

    sender = "#{Barong::App.config.sender_name} <#{Barong::App.config.sender_email}>"

    email_options = {
      subject: params[:subject],
      template_name: params[:template_name],
      from: sender,
      to: @user.email
    }
    attachments["requested.csv"] = @record.csv if @record.csv.present?
    mail(email_options)
  end
end
