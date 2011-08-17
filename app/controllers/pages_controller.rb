class PagesController < ApplicationController
  def index
    @featured_news = NewsItem.find(:first, :conditions => {:featured => true})
    @latest_news = NewsItem.find(:all, :order => "created_at DESC", :limit => 4, :conditions => {:featured => false})
  end

  def faq
  end

end
