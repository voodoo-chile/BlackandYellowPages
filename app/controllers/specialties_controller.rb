class SpecialtiesController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => [:search, :tag]
  
  def index
  end

  def new
  end

  def create
    @specialty = Specialty.new(params[:specialty])
    @specialty.user_id = current_user.id
    if @specialty.save
      redirect_to current_user, :notice => "Successfully created specialty."
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @specialty.update_attributes(params[:specialty])
      redirect_to current_user, :notice  => "Successfully updated specialty."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @specialty = Specialty.find(params[:id])
    @specialty.destroy
    redirect_to current_user, :notice => "Successfully removed specialty."
  end
  
  def search
    @specialties = Specialty.search(params)
    @location = params[:location]
    @near_specialties = Specialty.near(@location, 30)
  end

  def tag
    @specialties = Specialty.tagged_with(params[:id])
    @tag = params[:id]
  end
  
end
