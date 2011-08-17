class NewsItemsController < ApplicationController
  load_and_authorize_resource

  def index
    @news_items = NewsItem.all(:order => "created_at DESC")
  end
  
  def show
    @news_item = NewsItem.find(params[:id])
    @items = NewsItem.find(:all, :order => "created_at DESC", :limit => 10, :conditions => ["id != ?", @news_item.id])
  end

  def new
    @news_item = NewsItem.new
  end

  def create
    @news_item = NewsItem.new(params[:news_item])
    if @news_item.save
      redirect_to news_items_url, :notice => "Successfully created news item."
    else
      render :action => 'new'
    end
  end

  def edit
    @news_item = NewsItem.find(params[:id])
  end

  def update
    @news_item = NewsItem.find(params[:id])
    if @news_item.update_attributes(params[:news_item])
      redirect_to news_items_url, :notice  => "Successfully updated news item."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @news_item = NewsItem.find(params[:id])
    @news_item.destroy
    redirect_to news_items_url, :notice => "Successfully destroyed news item."
  end
  
  def feature
    @news_item.feature
    redirect_to news_items_url, :notice => "Featured news item changed."
  end
end
