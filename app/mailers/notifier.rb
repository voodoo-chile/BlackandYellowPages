class Notifier < ActionMailer::Base
  default :from => "Black & Yellow Pages Mailer <noreply@blackandyellowpages.com>"
  default_url_options[:host] = "blackandyellowpages.com"
  
  def activation_instructions(user)
    setup_email(user)
    subject		"Activation Instructions"
    @account_activation_url = register_url(user.perishable_token)
  end
  
  def password_reset(user)
    setup_email(user)
    subject 	"Password Reset Instructions"
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
  end
  
  def orphaned(user)
    setup_email(user)
    subject     "Your Black and Yellow Pages sponsor has withdrawn"
  end
  
  def adoption_offer(user, potential_sponsor)
    setup_email(user)
    subject  "You have received a Black and Yellow Pages sponsorship offer"
    @adopter = potential_sponsor
    @adopter_url = "http://blackandyellowpages.com/users/#{potential_sponsor.id}"
  end
  
  def offer_accepted(offer)
    setup_email(offer.potential_sponsor)
    subject "Your Black and Yellow Pages sponsorship offer has been accepted"
    @orphan = offer.user
  end
  
  def offer_rejected(offer)
    setup_email(offer.potential_sponsor)
    subject "Your Black and Yellow Pages sponsorship offer has been rejected"
    @orphan = offer.user
  end
  
  protected
  
  def setup_email(user)
    headers "Reply-to" => "noreply@blackandyellowpages.com"
    @recipients = user.email
    @sent_on = Time.now
  end
end
