class SponsorshipOffersController < ApplicationController
  load_and_authorize_resource

  def accept
    @sponsorship_offer.accept
    redirect_to current_user, :notice => "Offer accepted."
  end

  def reject
    @sponsorship_offer.reject
    redirect_to current_user, :notice => "Offer rejected."
  end

end
