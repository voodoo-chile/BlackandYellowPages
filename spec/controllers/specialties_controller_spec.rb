require File.dirname(__FILE__) + '/../spec_helper'

describe SpecialtiesController do
  fixtures :all
  render_views
  
  before(:each) do
    @ability = User.new
    @ability.extend(CanCan::Ability)
    @controller.stubs(:current_ability).returns(@ability)
  end

  it "index action should render index template" do
    @ability.can :read, Specialty
    get :index
    response.should render_template(:index)
  end

  it "new action should render new template" do
    @ability.can :create, Specialty
    get :new
    response.should render_template(:new)
  end

  describe "create action" do
    before(:each) do
      @ability.can :create, Specialty
      @user = Factory(:user)
      @controller.stub!(:current_user).and_return(@user)
    end
    
    def do_create
      put :create, :specialty => {:name => "value"}
    end
    
    describe "with valid model" do
      before(:each) do
        Specialty.stub!(:new).and_return(@specialty = mock_model(Specialty, :save => true).as_null_object)
      end
      
      it "creates a new specialty" do
        Specialty.should_receive(:new).with("name" => "value").and_return(@specialty)
        do_create
      end
      
      it "assigns the current_user as user" do
        @specialty.shoud_receive(:user_id).with(@user.id)
        do_create
      end
      
      it "saves the specialty" do
        @specialty.should_receive(:save).and_return(true)
        do_create
      end
      
      it "redirects to current_user" do
        do_create
        response.should redirect_to(@user)
      end
    end
    
    describe "with invalid model" do
      before(:each) do
        Specialty.stub!(:new).and_return(@specialty = mock_model(Specialty, :save => false).as_null_object)
      end
      
      it "creates the specialty" do
        Specialty.should_receive(:new).with("name" => "value").and_return(@specialty)
        do_create
      end
      
      it "saves the specialty" do
        @specialty.should_receive(:save).and_return(false)
        do_create
      end
      
      it "is a success" do
        do_create
        response.should be_success
      end
      
      it "re-renders the new template" do
        do_create
        response.should render_template(:new)
      end

    end
  end

  describe "edit action" do
    before(:each) do
      @ability.can :update, Specialty
      @specialty = Specialty.first
    end
    
    it "finds the specialty" do
      Specialty.should_receive(:find).with("1").and_return(@specialty)
      get :edit, :id => "1"
    end
    
    it "renders edit template" do
      get :edit, :id => Specialty.first
      response.should render_template(:edit)
    end
  end

  describe "update action" do
    before(:each) do
      @ability.can :update, Specialty
      @specialty = Specialty.first
      @controller.stub!(:current_user).and_return(current_user).as_null_object
      Specialty.stub!(:find).with("1").and_return(@specialty).as_null_object
    end
    
    def do_update
      post :update, :id => "1", :specialty => {}
    end
    
    describe "when model is valid" do
      before(:each) do
        @specialty.stub!(:update_attributes).and_return(true)
      end
      
      it "finds the specialty" do
        Specialty.should_receive(:find).with("1").and_return(@specialty)
        do_update
      end
      
      it "updates the specialty attributes" do
        @specialty.should_receive(:update_attributes).and_return(true)
        do_update
      end
      
      it "redirects to current_user" do
        do_update
        response.should redirect_to(current_user)
      end
    end
    
    describe "when model is invalid" do
      before(:each) do
        @specialty.stub!(:update_attributes).and_return(false)
        @controller.stub_chain(:current_user, :username).and_return(current_user.username)
      end    
      
      it "finds the specialty" do
        Specialty.should_receive(:find).with("1").and_return(@specialty)
        do_update
      end
      
      it "updates the specialty attributes" do
        @specialty.should_receive(:update_attributes).and_return(false)
        do_update
      end
      
      it "re-renders the edit template" do
        do_update
        response.should render_template(:edit)
      end
    end
    
  end


  it "destroy action destroys model and redirect to index action" do
    @controller.stub!(:current_user).and_return(current_user)
    @ability.can :destroy, Specialty
    specialty = Specialty.first
    delete :destroy, :id => specialty
    response.should redirect_to(current_user)
    Specialty.exists?(specialty.id).should be_false
  end
end
