class UsersController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :activate
  
  def index
  end

  def show
    if current_user  && current_user.id != @user.id
      @degrees_of_trust = current_user.degrees_of_trust(@user)
    end
    @tags = @user.username
    @user.specialties.each do |specialty|
      specialty.tag_list.each do |tag|
        @tags += ", #{tag}"
      end
    end
  end

  def new
    @sponsor_key = SponsorKey.find_by_key(params[:key])
    if @sponsor_key && @sponsor_key.valid_invite?
      @key = @sponsor_key.key
      render
    else
      redirect_to root_url, :alert => "Invalid invitation. Please check your invitation and try again."
    end
  end

  def create
    @sponsor_key = SponsorKey.find_by_key(params[:sponsor_key])
    if @sponsor_key && @sponsor_key.valid_invite?
      @user.sponsor_id = @sponsor_key.sponsor_id
      if @user.save
        TrustLink.make_sponsor_links(@sponsor_key.sponsor, @user)
        @sponsor_key.user = @user
        @sponsor_key.used = true
        @sponsor_key.save
        redirect_to root_url, :notice => "Successfully created new account. Check your email for activation instructions."
      else
        render :action => 'new'
      end
    else
      redirect_to root_url, :alert => "Invalid invitation. Please check your invitation and try again."
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to @user, :notice  => "Successfully updated user."
    else
      render :action => 'edit'
    end
  end
  
  def orphan
    @user.orphan
    TrustLink.break_sponsor_links(current_user, @user)
    redirect_to current_user, :notice => "Successfully orphaned #{@user.username}."
  end
  
  def invite
    @sponsor_key = current_user.generate_invite
    if current_user.errors[:base].blank?
      render
    else
      redirect_to current_user, :alert => current_user.errors[:base][0]
    end
  end
  
  def activate
    @user = User.find_using_perishable_token(params[:activation_code], 1.week) || (raise Exception)
    if @user.active?
      redirect_to login_url, :notice => "That user is already activated."
    elsif @user.activate!(params[:activation_code])
      redirect_to login_url, :notice => "Your account has been activated."
    else
      redirect_to root_url, :alert => "Please retry activation."
    end
  end
  
  def orphanage
    @users = User.find(:all, :conditions => {:sponsor_id => 0})
  end
  
  def adopt
    prior_offer = SponsorshipOffer.find(:first, :conditions => {:user_id => @user.id, :sponsor_id => current_user.id, :status => "pending"})
    if !prior_offer.blank? && prior_offer.expiration >= Date.today
      redirect_to current_user, :alert => "You have already offered that sponsorship."
    elsif !prior_offer.blank? && prior_offer.expiration < Date.today
      prior_offer.expire
      current_user.adopt(@user)
      redirect_to current_user, :notice => "Your sponsorship offer has been renewed."
    else
      current_user.adopt(@user)
      redirect_to current_user, :notice => "Your sponsorship offer has been sent."
    end
  end
  
  def trust_links
    @incoming_links = TrustLink.find(:all, :conditions => {:trustee => @user.id})
  end
  
  def sever_trust
    @trust_link = TrustLink.find(:first, :conditions => {:user_id => current_user.id, :trustee => @user.id})
    @trust_link.destroy
    redirect_to @user, :notice => "Trust link severed."
  end
  
  def trust
    if @user != current_user
      TrustLink.create(:user_id => current_user.id, :trustee => @user.id)
      redirect_to @user
    else
      redirect_to @user, :alert => "We're sure you trust yourself, but that link wouldn't be helpful."
    end
  end
  
end
