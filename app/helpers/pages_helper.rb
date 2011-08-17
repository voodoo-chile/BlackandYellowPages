module PagesHelper

  def get_featured_listings
    @specialties = Specialty.find(:all, :order => "created_at DESC", :limit => 5)
  end
  
end
