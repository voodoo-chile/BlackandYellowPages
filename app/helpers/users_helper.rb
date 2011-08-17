module UsersHelper

  def contact(user)
    @user.contact ||= Contact.new 
  end
  
  def auto_select_text_area_tag(name, value = nil, options = {})
    text_area_tag(name,
                  value,
                  { :onclick => "this.select()",
                  :readonly => "true" }.merge(options))
  end
  
  def prior_trust?
    @prior_trust = false
    @trust = TrustLink.find_by_user_id(current_user.id, :conditions => {:trustee => @user.id})
    if @trust
      @prior_trust = true
    end 
  end
  
  def incoming_trust_count
    @trust_in = TrustLink.count( :conditions => "trustee = #{@user.id}" )
  end
  
  def outgoing_trust_count
    @trust_out = @user.trust_links.count
  end
  
  def sponsorship_offered?(user)
    @offer = SponsorshipOffer.find(:first, :conditions => ["user_id =? AND sponsor_id = ? AND status = ?", user.id, current_user.id, "pending"])
    if @offer
      true
    else
      false
    end
  end
  
  def get_news_items
    @items = NewsItem.find(:all, :order => "created_at DESC", :limit => 5)
  end
  
end
