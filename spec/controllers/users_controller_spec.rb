require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  fixtures :all
  
  before(:each) do
    @ability = User.new
    @ability.extend(CanCan::Ability)
    @controller.stubs(:current_ability).returns(@ability)
  end

  it "index action should render index template" do
    @ability.can :read, User
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    @ability.can :read, User
    user = User.first
    get :show, :id => user.id
    assigns(:user).should == user
    response.should render_template(:show)
  end

  it "new action with bad key redirects to root" do
    @ability.can :create, User
    get :new
    response.should redirect_to(root_url)
  end
  
  it "new action with valid key renders new template" do
    @ability.can :create, User
    invite = Factory(:sponsor_key)
    get :new, :key => invite.key
    response.should render_template(:new)
  end

  describe "create action" do
    before(:each) do
      @ability.can :create, User
      SponsorKey.stub!(:find_by_key).with("1234").and_return(@sponsor_key = mock_model(SponsorKey, :key => "1234").as_null_object)
    end
    
    def do_create
      post :create, :user =>{:username=>"value"}, :sponsor_key => "1234"
    end
      
    describe "with a valid user" do
      before(:each) do    
        @sponsor_key.stub!(:valid_invite?).and_return(true)
        User.stub!(:new).and_return(@user = mock_model(User, :save=>true).as_null_object)
      end
      
      it "should find the sponsor key" do
        SponsorKey.should_receive(:find_by_key).with("1234").and_return(@sponsor_key)
        do_create
      end
  
      it "should create the user" do
        User.should_receive(:new).with("username"=>"value").and_return(@user)
        do_create
      end
  
      it "should save the user" do
        @user.should_receive(:save).and_return(true)
        do_create
      end
  
      it "should be redirect" do
        do_create
        response.should be_redirect
      end
  
      it "should assign user" do
        do_create
        assigns(:user).should == @user
      end
  
      it "should redirect to the root path" do
        do_create
        response.should redirect_to(root_url)
      end
    end

    describe "with an invalid user" do
      before(:each) do    
        User.stub!(:new).and_return(@user = mock_model(User, :save=>false).as_null_object)
        SponsorKey.stub!(:valid_invite?).and_return(true)
      end
    
      it "should create the user" do
        User.should_receive(:new).with("username" =>"value").and_return(@user)
        do_create
      end
  
      it "should save the user" do
        @user.should_receive(:save).and_return(false)
        do_create
      end
  
      it "should be success" do
        do_create
        response.should be_success
      end
  
      it "should assign user" do
        do_create
        assigns(:user).should == @user
      end
  
      it "should re-render the new form" do
        do_create
        response.should render_template("new")
      end
    end
  end
  
  describe "create action with an invalid key" do 
    it "should redirect to root" do
      post :create, :user =>{:username=>"value"}
      response.should redirect_to(root_url)
    end
  end

  it "edit action should render edit template" do
    @ability.can :update, User
    get :edit, :id => User.first
    response.should render_template(:edit)
  end
  
  describe "update action" do
    before(:each) do
      @ability.can :update, User
      @user = mock_model(User).as_null_object
      User.stub!(:find).with("1").and_return(@user)
    end
    
    def do_put
      put :update, :id => "1" , :user => {}
    end
    
    describe "with valid user data" do
      before(:each) do
        @user.stub!(:update_attributes).and_return(true)
      end
      
      it "receives find and returns user" do
        User.should_receive(:find).with("1").and_return(@user)
        do_put
      end
      
      it "receives updated user fields" do
        @user.should_receive(:update_attributes).and_return(true)
        do_put
      end
      
      it "redirects to user url" do
        do_put
        response.should redirect_to(@user)
      end
      
    end
    
    describe "with an invalid user" do
      before(:each) do
        @user.stub!(:update_attributes).and_return(false)
      end
      
      it "receives find and returns user" do
        User.should_receive(:find).with("1").and_return(@user)
        do_put
      end
      
      it "receives updated user fields" do
        @user.should_receive(:update_attributes).with({}).and_return(false)
        do_put
      end
      
      it "should be a success" do
        do_put
        response.should be_success
      end
      
      it "should re-render edit form" do
        do_put
        response.should render_template(:edit)
      end
    end
  end
  
  describe "orphange action" do
    before(:each) do
      @ability.can :orphanage, User
      User.stub!(:find).and_return(@users = mock_model(User, :sponsor_id => 0).as_null_object)
    end
    it "finds orphaned users" do
      User.should_receive(:find).with(:all, :conditions => {:sponsor_id => 0}).and_return(@users)
      get :orphanage
    end
  
    it "renders the orphanage template" do
      get :orphanage
      response.should render_template(:orphanage)
    end
  end
  
  describe "invite action" do
    before(:each) do
      @ability.can :invite, User
      @controller.stub!(:current_user).and_return(@c_user = mock_model(User, :phone => "3105551212").as_null_object)
      User.stub!(:find).and_return(@c_user)
      SponsorKey.stub!(:create).and_return(@sponsor_key = mock_model(SponsorKey, :save => true))
    end
    
    it "finds the current user" do
      User.should_receive(:find).and_return(@c_user)
      get :invite, :id => @c_user.id
    end
    
    it "triggers generation of a new sponsor key" do
      @c_user.should_receive(:generate_invite).and_return(@sponsor_key)
      get :invite, :id => @c_user.id
    end
    
    it "renders the invite template" do
      @ability.can :invite, User
      get :invite, :id => @c_user.id
      response.should render_template(:invite)
    end
  end
  
  describe "trust_links action" do
    before(:each) do
      @ability.can(:trust_links, User)
      User.stub!(:find).with("1").and_return(@user = mock_model(User).as_null_object)
    end
    
    it "finds the user" do
      User.should_receive(:find).with("1").and_return(@user)
      get :trust_links, :id => "1"
    end
    
    it "renders the trust_links template" do
      get :trust_links, :id => "1"
      response.should render_template(:trust_links)
    end
  end


end
