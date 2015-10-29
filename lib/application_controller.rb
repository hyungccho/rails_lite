class ApplicationController
  def protect_from_forgery(options = {})
    @protect_from_forgery = true
  end

  def form_authenticity_token
    @form_authenticity_token ||= SecureRandom.urlsafe_base64
  end

  def protect_from_forgery?
    @protect_from_forgery
  end
end
