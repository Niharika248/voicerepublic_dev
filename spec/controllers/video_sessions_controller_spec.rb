require 'spec_helper'
require 'faker'
require 'kluuu_exceptions'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe VideoSessionsController do
  
  before do
    @user = FactoryGirl.create(:user, available: :online, last_request_at: Time.now)  
    @user.balance_account = Balance::Account.create(:currency => 'EUR')
    @klu = FactoryGirl.create(:published_kluuu, user_id: @user.id)
    guest_password = Faker::Lorem.characters(8)
    host_password = Faker::Lorem.characters(8)
    hash_create =
          {
            :returncode => "SUCCESS", :meetingID => "test_id",
            :attendeePW => guest_password, :moderatorPW => host_password,
            :hasBeenForciblyEnded => "false", :messageKey => {}, :message => {}
          }
          
    @api_mock = mock(VideoSystemApi::VideoSystemApi)
    @api_mock.stub(:create_meeting).and_return(hash_create)
    @api_mock.stub(:join_meeting_url).and_return('http://www.kluuu.com')
    @server_mock = mock_model(VideoServer)
    @server_mock.stub(:api).and_return(@api_mock)
    @server_mock.stub(:first).and_return(@server_mock)
    @server_mock.stub(:where).and_return(@server_mock)
    @server_mock.stub(:each).and_return(@server_mock)
    VideoServer.stub(:activated).and_return(@server_mock)
  end

  # This should return the minimal set of attributes required to create a valid
  # VideoSession. As you add validations to VideoSession, be sure to
  # update the return value of this method accordingly.
  def valid_registered_video_session_attributes
    FactoryGirl.attributes_for(:registered_video_session)
  end
  
  def valid_anonymous_video_session_attributes
    FactoryGirl.attributes_for(:anonymous_video_session)
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # VideoSessionsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all video_sessions as @video_sessions" do
      registered_video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
      anonymous_video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
      get :index, {}, valid_session
      assigns(:video_sessions).should eq([registered_video_session, anonymous_video_session])
    end
  end

  describe "GET show" do
    it "assigns the requested video_session as @video_session with registered participants" do
      registered_video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
      controller.stub :current_user => registered_video_session.host_participant.user
      get :show, {:id => registered_video_session.to_param}, valid_session
      assigns(:participant).user_id.should == registered_video_session.host_participant.user_id 
      assigns(:video_session).should eq(registered_video_session)
    end
    
    it "assigns the requested video_session as @video_session with anonymous guest participant" do
      anonymous_video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id, :calling_user_id => 'abcdefghi')
      get :show, {:id => anonymous_video_session.to_param}, valid_session
      assigns(:participant)
      assigns(:video_session).should eq(anonymous_video_session)
    end
    
    it "assigns the requested video_session as @video_session with anonymous participant" do
      anonymous_video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id, :calling_user_id => 'abcdefghi')
      controller.stub :current_user => anonymous_video_session.host_participant.user
      get :show, {:id => anonymous_video_session.to_param}, valid_session
      assigns(:participant).user_id.should == anonymous_video_session.host_participant.user_id 
      assigns(:video_session).should eq(anonymous_video_session)
    end
  end

  describe "GET new" do
    it "renders the new form" do
      get :new, {:klu_id => @klu.id, :format => 'js'}, valid_session
      assigns(:klu).should eq(@klu)
      response.should render_template('new')
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new VideoSession with registered Participants" do
        expect {
          xhr :post, :create, {:video_session => valid_registered_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
        }.to change(VideoSession::Registered, :count).by(1)
      end
      
      it "creates a new VideoSession with one anonymous Participants" do
        expect {
          xhr :post, :create, {:video_session => valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
        }.to change(VideoSession::Anonymous, :count).by(1)
      end
      
      it "creates a new Registered Incoming Call Notification" do
        expect {
          xhr :post, :create, {:video_session => valid_registered_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
        }.to change(Notification::IncomingCall, :count).by(1)
      end
      
      it "creates a new Anonymous Incoming Call Notification" do
        expect {
          xhr :post, :create, {:video_session => valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
        }.to change(Notification::IncomingCall, :count).by(1)
      end
      
      it "assigns a newly created video_session with registered participants as @video_session" do
        xhr :post, :create, {:video_session => valid_registered_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
        assigns(:video_session).should be_a(VideoSession::Base)
        assigns(:video_session).should be_persisted
      end
      
      it "assigns a newly created video_session with one anonymous participant as @video_session" do
        xhr :post, :create, {:video_session => valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
        assigns(:video_session).should be_a(VideoSession::Base)
        assigns(:video_session).should be_persisted
      end
      
      it "persists a newly created Registered Incoming Call Notification associated to KluuU Owner" do
        video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
        video_session.host_participant.user.notifications.count.should == 1
      end
     
      it "persists a newly created Anonymous Incoming Call Notification associated to KluuU Owner" do
        video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
        video_session.host_participant.user.notifications.count.should == 1
      end
      
      it "persists a newly created Registered Incoming Call Notification with calling users id as other_id" do
        video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
        video_session.host_participant.user.notifications.first.other_id.should == video_session.guest_participant.user.id
      end

      it "persists a newly created Anonymous Incoming Call Notification with calling users id as other_id" do
        video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
        video_session.host_participant.user.notifications.first.anon_id.should == video_session.guest_participant.user_cookie_session_id
      end
      
      it "renders the dialog for calling someone per video_session for registered participants" do
        xhr :post, :create, {:video_session => valid_registered_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session
        response.should render_template("create")
      end
      
      it "renders the dialog for calling someone per video_session for one anonymous participant" do
        xhr :post, :create, {:video_session => valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session
        response.should render_template("create")
      end
    end
    
    describe "with invalid params" do
      it "renders error flash" do
        # Trigger the behavior that occurs when invalid params are submitted
        VideoSession::Base.any_instance.stub(:save).and_return(false)
        xhr :post, :create, {:video_session => {:klu_id => @klu.id}}, valid_session, :format => 'js'
        response.should render_template 'shared/error_flash'
      end
    end
    
    describe "with an exception thrown" do
      it "renders an error flash if klu not published" do
        klu = FactoryGirl.create(:unpublished_kluuu, user_id: @user.id) 
        xhr :post, :create, {:video_session => valid_registered_video_session_attributes.merge(:klu_id => klu.id)}, valid_session, :format => 'js'
        response.should render_template 'shared/alert_flash'
      end
      it "renders an error flash if klu user is the calling user" do
        controller.stub :current_user => @user
        xhr :post, :create, {:video_session => valid_registered_video_session_attributes.merge(:klu_id => @klu.id, :calling_user_id => @user.id)}, valid_session, :format => 'js'
        response.should render_template 'shared/alert_flash'
      end
      it "directs to the message controller if klu user is not available" do
        user = FactoryGirl.create(:user, available: :offline, last_request_at: Time.now)  
        klu = FactoryGirl.create(:published_kluuu, user_id: user.id)
        xhr :post, :create, {:video_session => valid_registered_video_session_attributes.merge(:klu_id => klu.id)}, valid_session, :format => 'js' 
        response.should render_template 'user_unavailable'
      end
      it "directs to the credit account controller if registered calling user does not have an account" do
        user = FactoryGirl.create(:user, available: :online, last_request_at: Time.now)  
        klu = FactoryGirl.create(:published_kluuu, user_id: @user.id, charge_type: 'minute')
        controller.stub :current_user => user
        xhr :post, :create, {:video_session => valid_registered_video_session_attributes.merge(:klu_id => klu.id, :calling_user_id => user.id)}, valid_session, :format => 'js' 
        response.should render_template 'no_account'
      end
      it "directs to the registration page if an anonymous calling user tries to call a non-free kluuu" do
        klu = FactoryGirl.create(:published_kluuu, user_id: @user.id, charge_type: 'minute')
        xhr :post, :create, {:video_session => valid_anonymous_video_session_attributes.merge(:klu_id => klu.id)}, valid_session, :format => 'js' 
        response.should render_template 'anonymous_sign_up'
      end
      it "directs to the credit account controller if minute registered calling user does not have enough money" do
        user = FactoryGirl.create(:user, available: :online, last_request_at: Time.now)  
        balance_account =  FactoryGirl.create(:balance_account, user_id: user.id, balance_cents: 0)  
        klu = FactoryGirl.create(:published_kluuu, user_id: @user.id, charge_type: 'minute', charge_amount: 200)
        controller.stub :current_user => user
        xhr :post, :create, {:video_session => valid_registered_video_session_attributes.merge(:klu_id => klu.id, :calling_user_id => user.id)}, valid_session, :format => 'js' 
        response.should render_template 'no_funds'
      end
      it "directs to the credit account controller if fix registered calling user does not have enough money" do
        user = FactoryGirl.create(:user, available: :online, last_request_at: Time.now)  
        balance_account =  FactoryGirl.create(:balance_account, user_id: user.id, balance_cents: 0)  
        klu = FactoryGirl.create(:published_kluuu, user_id: @user.id, charge_type: 'fix', charge_amount: 200)
        controller.stub :current_user => user
        xhr :post, :create, {:video_session => valid_registered_video_session_attributes.merge(:klu_id => klu.id, :calling_user_id => user.id)}, valid_session, :format => 'js' 
        response.should render_template 'no_funds'
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested registered video_session" do
        video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
        # Assuming there are no other video_sessions in the database, this
        # specifies that the VideoSession created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        VideoSession::Base.any_instance.should_receive(:save)
        xhr :put, :update, {:id => video_session.to_param, :video_session => {}}, valid_session, :format => 'js'
      end
      
      it "updates the requested anonymous video_session" do
        video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
        # Assuming there are no other video_sessions in the database, this
        # specifies that the VideoSession created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        VideoSession::Base.any_instance.should_receive(:save)
        xhr :put, :update, {:id => video_session.to_param, :video_session => {}}, valid_session, :format => 'js'
      end

      it "assigns the requested video_session as @video_session" do
        video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
        xhr :put, :update, {:id => video_session.to_param, :video_session => valid_registered_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
        assigns(:video_session).should eq(video_session)
      end
      
      it "creates a video room for the registered video_session" do
        video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
        expect {
          xhr :put, :update, {:id => video_session.to_param, :video_session => valid_registered_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
        }.to change(VideoRoom, :count).by(1)
      end
      
      it "creates a video room for the anonymous video_session" do
        video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
        expect {
          xhr :put, :update, {:id => video_session.to_param, :video_session => valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
        }.to change(VideoRoom, :count).by(1)
      end
      
      it "creates links for the registered video_session users" do
        video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
        @api_mock.should_receive(:join_meeting_url).twice
        video_session.guest_participant.room_url.should be_nil
        video_session.host_participant.room_url.should be_nil
        xhr :put, :update, {:id => video_session.to_param, :video_session => valid_registered_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
        assigns(:video_session).host_participant.room_url.should == 'http://www.kluuu.com'
        assigns(:video_session).guest_participant.room_url.should == 'http://www.kluuu.com'
      end
      
      it "creates links for the anonymous video_session users" do
        video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
        @api_mock.should_receive(:join_meeting_url).twice
        video_session.guest_participant.room_url.should be_nil
        video_session.host_participant.room_url.should be_nil
        xhr :put, :update, {:id => video_session.to_param, :video_session => valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
        assigns(:video_session).host_participant.room_url.should == 'http://www.kluuu.com'
        assigns(:video_session).guest_participant.room_url.should == 'http://www.kluuu.com'
      end
      
      it "creates a call accepted notification for registered session" do
        video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
        xhr :put, :update, {:id => video_session.to_param, :video_session => valid_registered_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
        Notification::CallAccepted.where('video_session_id = ?', video_session.id).count.should == 1
      end
      
      it "creates a call accepted notification for anonymous session" do
        video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
        xhr :put, :update, {:id => video_session.to_param, :video_session => valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
        Notification::CallAccepted.where('video_session_id = ?', video_session.id).count.should == 1
      end
      
      it "redirects to the registered video_session" do
        video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
        xhr :put, :update, {:id => video_session.to_param, :video_session => valid_registered_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
        response.should redirect_to(video_session_path(:id => video_session.id))
      end
      
      it "redirects to the anonymous video_session" do
        video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
        xhr :put, :update, {:id => video_session.to_param, :video_session => valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
        response.should redirect_to(video_session_path(:id => video_session.id))
      end
      
    end

    describe "with invalid params" do
      it "assigns the registered video_session as @video_session" do
        video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
        # Trigger the behavior that occurs when invalid params are submitted
        VideoSession::Base.any_instance.stub(:save).and_return(false)
        xhr :put, :update, {:id => video_session.to_param, :video_session => {}}, valid_session, :format => 'js'
        assigns(:video_session).should eq(video_session)
      end
      
      it "assigns the anonymous video_session as @video_session" do
        video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
        # Trigger the behavior that occurs when invalid params are submitted
        VideoSession::Base.any_instance.stub(:save).and_return(false)
        xhr :put, :update, {:id => video_session.to_param, :video_session => {}}, valid_session, :format => 'js'
        assigns(:video_session).should eq(video_session)
      end
    end
    
    describe "if room cannot be created" do
      context "because no video_server is available" do
        it "does not create a video room for the registered video_session" do
          @server_mock.stub(:first).and_return(nil)
          video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
          xhr :put, :update, {:id => video_session.to_param, :video_session => valid_registered_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
          Notification::VideoSystemError.where('video_session_id = ?', video_session.id).count.should == 1
          response.should render_template 'shared/alert_flash'
        end
        
        it "does not create a video room for the anonymous video_session" do
          @server_mock.stub(:first).and_return(nil)
          video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
          xhr :put, :update, {:id => video_session.to_param, :video_session => valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)}, valid_session, :format => 'js'
          Notification::VideoSystemError.where('video_session_id = ?', video_session.id).count.should == 1
          response.should render_template 'shared/alert_flash'
        end
      end
    end
    
  end

  describe "DELETE destroy" do
    it "destroys the requested registered video_session if guest cancels the session" do
      video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
      expect {
        xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.guest_participant.id}, valid_session, :format => 'js'
      }.to change(VideoSession::Registered, :count).by(-1)
    end
    
    it "destroys the requested registered video_session if host cancels the session" do
      video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
      expect {
        xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.host_participant.id}, valid_session, :format => 'js'
      }.to change(VideoSession::Registered, :count).by(-1)
    end
    
    it "deletes all preceding notifications if guest cancels the session" do
      video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
      expect {
        xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.guest_participant.id}, valid_session, :format => 'js'
      }.to change(Notification::IncomingCall, :count).by(-1)
    end
    
    it "deletes all preceding notifications if host cancels the session" do
      video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
      expect {
        xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.guest_participant.id}, valid_session, :format => 'js'
      }.to change(Notification::IncomingCall, :count).by(-1)
    end
    
    it "generates a missed call notification for registered video sessions if canceling user is guest" do
      video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
      expect {
        xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.guest_participant.id}, valid_session, :format => 'js'
      }.to change(Notification::MissedCall, :count).by(1)
    end
    
    it "generates a rejected call notification for registered video sessions if canceling user is host" do
      video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
      expect {
        xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.host_participant.id}, valid_session, :format => 'js'
      }.to change(Notification::CallRejected, :count).by(1)
    end
    
    it "missed call renders a notification for the host" do
      video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
      xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.guest_participant.id}, valid_session, :format => 'js'
      response.should render_template 'notifications/missed_call'
    end
    
    it "rejected call renders a notification for the guest" do
      video_session = VideoSession::Registered.create! valid_registered_video_session_attributes.merge(:klu_id => @klu.id)
      xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.host_participant.id}, valid_session, :format => 'js'
      response.should render_template 'notifications/call_rejected'
    end
    
    it "destroys the requested anonymous video_session if guest cancels the session" do
      video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
      expect {
        xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.guest_participant.id}, valid_session, :format => 'js'
      }.to change(VideoSession::Anonymous, :count).by(-1)
    end
    
    it "destroys the requested anonymous video_session if host cancels the session" do
      video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
      expect {
        xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.host_participant.id}, valid_session, :format => 'js'
      }.to change(VideoSession::Anonymous, :count).by(-1)
    end
    
    it "deletes all preceding notifications if guest cancels the session" do
      video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
      expect {
        xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.guest_participant.id}, valid_session, :format => 'js'
      }.to change(Notification::IncomingCall, :count).by(-1)
    end
    
    it "deletes all preceding notifications if host cancels the session" do
      video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
      expect {
        xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.guest_participant.id}, valid_session, :format => 'js'
      }.to change(Notification::IncomingCall, :count).by(-1)
    end
    
    it "generates a missed call notification for anonymous video sessions if canceling user is guest" do
      video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
      expect {
        xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.guest_participant.id}, valid_session, :format => 'js'
      }.to change(Notification::MissedCall, :count).by(1)
    end
    
    it "generates a rejected call notification for anonymous video sessions if canceling user is host" do
      video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
      expect {
        xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.host_participant.id}, valid_session, :format => 'js'
      }.to change(Notification::CallRejected, :count).by(1)
    end
    
    it "missed call renders a notification for the host" do
      video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
      xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.guest_participant.id}, valid_session, :format => 'js'
      response.should render_template 'notifications/missed_call'
    end
    
    it "rejected call renders a notification for the guest" do
      video_session = VideoSession::Anonymous.create! valid_anonymous_video_session_attributes.merge(:klu_id => @klu.id)
      xhr :delete, :destroy, {:id => video_session.to_param, :canceling_participant_id => video_session.host_participant.id}, valid_session, :format => 'js'
      response.should render_template 'notifications/call_rejected'
    end
  end
end
