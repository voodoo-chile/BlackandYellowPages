class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    
    # Authorization error messages defined in /config/locales/en.yml
    
    user ||= User.new
    if user.role?(:admin)
      can :manage, :all
      can :invite, User
      cannot :orphan, User do |person|
        person.sponsor != user
      end
    
    elsif user.role?(:agorist)
      can :show, User
      can :update, User do |person|
        person.id == user.id
      end
      can :trust_links, User
      can :trust, User
      can :create, :contact
      can :invite, User
      can :orphan, User do |person|
        person.sponsor_id == user.id
      end
      can :orphanage, User
      can :adopt, User do |person|
        person.roles.include?('orphan') && person.no_relationship?(user)
      end
      can :update, Contact do |contact|
        contact.try(:user) == user
      end
      can :create, Specialty
      can :manage, Specialty do |specialty|
        specialty.try(:user) == user
      end
      cannot :index, Specialty
      can :create, TrustLink
      can :destroy, TrustLink do |link|
        link.try(:user) == user
      end
      can :show, NewsItem

    elsif user.role?(:orphan)
      can :show, User
      can :update, User do |person|
        person.id == user.id
      end
      can :trust_links, User
      can :orphanage, User
      can :orphan, User do |person|
        person.sponsor_id == user.id
      end
      can :create, :contact
      can :update, Contact do |contact|
        contact.try(:user) == user
      end
      can :manage, Specialty do |specialty|
        specialty.try(:user) == user
      end
      cannot :index, Specialty
      can :accept, SponsorshipOffer do |offer|
        offer.try(:user) == user
      end
      can :reject, SponsorshipOffer do |offer|
        offer.try(:user) == user
      end
      can :create, TrustLink
      can :destroy, TrustLink do |link|
        link.try(:user) == user
      end
      can :show, NewsItem

    else
      can :show, User
      can :create, User
      can :activate, User
      can :trust_links, User
      can :search, Specialty
      can :show, NewsItem
    end
    
  end
  
end
