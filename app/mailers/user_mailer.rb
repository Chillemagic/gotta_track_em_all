class UserMailer < ApplicationMailer # Devise::Mailer
  default from: "mail@trackem.tech"

  def welcome
    @user = params[:user]

    mail(to: @user.email, subject: "Welcome to GTEA")
  end
end
