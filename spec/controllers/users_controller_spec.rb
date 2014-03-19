require 'spec_helper'

describe UsersController do

  before do
    @user = FactoryGirl.create(:user)
    request.env['warden'].stub :authenticate! => @user
    controller.stub :current_user => @user
  end
  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    FactoryGirl.attributes_for(:user)
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET venues" do
    it "assigns users venues as @venues" do
      _venue = FactoryGirl.create(:venue)

      get :venues, {:id => _venue.user.to_param}, valid_session
      assigns(:venues).should include(_venue)
    end
  end

  describe "GET show" do
    it "assigns the requested user as @user" do
      user = User.create! valid_attributes
      get :show, {:id => user.to_param}, valid_session
      assigns(:user).should eq(user)
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested user" do
        # Assuming there are no other users in the database, this
        # specifies that the User created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        User.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => @user.to_param, :user => {'these' => 'params'}}, valid_session
      end

      it "updates the 'about' attribute of account" do
        @user.account.about.should be_nil
        put :update, {
          :id => @user.to_param,
          :user => {:account_attributes => { :about => "spec about" }}
        }, valid_session
        @user.reload.account.about.should == "spec about"
      end

      it "assigns the requested user as @user" do
        put :update, {:id => @user.to_param, :user => valid_attributes}, valid_session
        assigns(:user).should eq(@user)
      end

      it "redirects to the user" do
        put :update, {:id => @user.to_param, :user => @user.attributes[:email]  }, valid_session  #
        response.should redirect_to(user_url(:id => @user))
      end
    end

    describe "with invalid params"  do
      it "assigns the user as @user" do
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.stub(:save).and_return(false)
        put :update, {:id => @user.to_param, :user => {}}, valid_session
        assigns(:user).should eq(@user)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.stub(:save).and_return(false)
        put :update, {:id => @user.to_param, :user => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

end
