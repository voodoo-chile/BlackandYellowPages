class Specialty < ActiveRecord::Base
  acts_as_taggable
  attr_accessible :name, :url, :phone, :email, :line1, :line2, :street, :city, :region, :country, :postal_code, :user_id, :tag_list
  
  belongs_to :user
  
  validates_format_of :email, :with => /^.+@.+\..+$/, :allow_blank => true
  validates_format_of :phone,
                                         :message => "must be a valid telephone number.",
                                         :with => /^[\(\)0-9\- \+\.]{10,20} *[extension\.]{0,9} *[0-9]{0,5}$/i,
                                         :allow_blank => true 
  validates_format_of :url, :with => URI::regexp(%w(http https)), 
                                                  :allow_blank => true,
                                                  :message => "must be a valid website address."
                                                  
  geocoded_by :full_address do |obj,results|
    if geo = results.first
      obj.latitude = geo.latitude
      obj.longitude = geo.longitude
      obj.city = geo.city
      obj.region = geo.state_code
      obj.country = geo.country_code
      obj.postal_code = geo.postal_code
    end
  end
  after_validation :geocode
  
  scope :listing_search
  
  def self.search(params)
    if !params[:search].blank? && !params[:location].blank?
      if !params[:distance].blank?
        @specialties = Specialty.tagged_with(params[:search]).near(params[:location], params[:distance])
        terms = "%"+params[:search]+"%"
        listing_search = Specialty.scoped.where(['name LIKE ? OR line1 LIKE ? OR line2 LIKE ?', terms, terms, terms]).near(params[:location], params[:distance])
        listing_search.each do |l|
          @specialties << l unless @specialties.detect {|h| h==l}
        end
      else
        @specialties = Specialty.tagged_with(params[:search]).near(params[:location], 30)
        terms = "%"+params[:search]+"%"
        listing_search = Specialty.scoped.where(['name LIKE ? OR line1 LIKE ? OR line2 LIKE ?', terms, terms, terms]).near(params[:location], 30)
        listing_search.each do |l|
          @specialties << l unless @specialties.detect {|h| h==l}
        end
      end
    elsif params[:search].blank? && !params[:location].blank?
      if !params[:distance].blank?
        @specialties = Specialty.near(params[:location], params[:distance])
      else
        @specialties = Specialty.near(params[:location], 30)
      end
    elsif !params[:search].blank? && params[:location].blank?
      @specialties = Specialty.tagged_with(params[:search])
      terms = "%"+params[:search]+"%"
      listing_search = Specialty.find(:all, :conditions => ['name LIKE ? OR line1 LIKE ? OR line2 LIKE ?', terms, terms, terms])
      listing_search.each do |l|
        @specialties << l unless @specialties.detect {|h| h==l}
      end
    else
      @specialties = Specialty.all
    end
  end

  private
  
  def full_address
    [street, city, region, country, postal_code].compact.join(', ')
  end

end
