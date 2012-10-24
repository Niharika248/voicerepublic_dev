class VideoSession::Registered < VideoSession::Base
  
  has_one :host_participant, :autosave => true, :class_name => 'Participant::Registered', :foreign_key => 'video_session_id', :dependant => :destroy
  has_one :guest_participant, :autosave => true, :class_name => 'Participant::Registered', :foreign_key => 'video_session_id', :dependant => :destroy
  
  before_create :prepare_one_on_one_video_session
  after_create :create_incoming_call_notification
  
  before_update :prepare_room_for_video_session
  after_create :create_call_accepted_notification
  
  after_destroy :create_call_canceled_notification
  
  validates_associated :host_participant, :guest_participant


 private
 
 def prepare_one_on_one_video_session   
   @klu = Klu.find(self.klu_id)
   
   @klu_user = @klu.user
   
   #create guest (calling) participant for video_session
   self.guest_participant = Participant::Registered.new(:user_id => self.calling_user_id, :video_session_role => 'guest')
   
   #create host participant for video_session 
   self.host_participant = Participant::Registered.new(:user_id => @klu_user.id, :video_session_role => 'host')
  
  end
  
  def create_incoming_call_notification
    Notification::IncomingCall.create(:user_id => @klu_user.id, :other_id => self.calling_user_id, :video_session_id => self.id)  
  end
  
  def prepare_room_for_video_session
    #2, "#{t('sezzions_controller.update.chat_system_welcome')}", klu_show_url(:id => offer.id), request.host
    
    #raise KluuUException::RoomCreationFailed create_room_creation_failed_notification
      
  end
  
  def create_video_session_links_for_participants
    #raise KluuUException::LinkCreationFailed create_room_creation_failed_notification
  end  
  
  def create_call_accepted_notification  
  end
  
  def create_room_creation_failed_notification
  end
  
  def create_call_canceled_notification 
    if self.canceling_participant_id.to_i == self.guest_participant.id.to_i
      Notification::MissedCall.create(:user_id => self.host_participant.user_id, :other_id => self.guest_participant.user_id, :video_session_id => self.id, :url => Rails.application.routes.url_helpers.user_path(:id => self.guest_participant.user_id))
    else  
      Notification::CallRejected.create(:user_id => self.guest_participant.user_id, :other_id => self.host_participant.user_id, :video_session_id => self.id)
    end
  end
end