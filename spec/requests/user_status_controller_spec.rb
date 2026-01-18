# frozen_string_literal: true

require 'rails_helper'

describe UserStatusController do
  fab!(:user) { Fabricate(:user) }
  fab!(:allowed_group) { Fabricate(:group) }
  fab!(:admin) { Fabricate(:admin) }
  
  before do
    SiteSetting.enable_user_status = true
    SiteSetting.user_status_allowed_groups = allowed_group.id.to_s
  end
  
  describe "#set" do
    it "allows users in allowed group to set status" do
      allowed_group.add(user)
      sign_in(user)
      
      put "/user-status.json", params: { description: "test", emoji: "tooth" }
      expect(response.status).to eq(200)
      expect(user.reload.user_status.description).to eq("test")
    end
    
    it "blocks users not in allowed group" do
      sign_in(user)
      
      put "/user-status.json", params: { description: "test", emoji: "tooth" }
      expect(response.status).to eq(403)
      expect(user.reload.user_status).to be_nil
    end
    
    it "allows admins regardless of group" do
      sign_in(admin)
      
      put "/user-status.json", params: { description: "test", emoji: "tooth" }
      expect(response.status).to eq(200)
    end
    
    it "allows all users when no groups configured" do
      SiteSetting.user_status_allowed_groups = ""
      sign_in(user)
      
      put "/user-status.json", params: { description: "test", emoji: "tooth" }
      expect(response.status).to eq(200)
    end
  end
  
  describe "#update" do
    it "allows users in allowed group to update status" do
      allowed_group.add(user)
      user.set_status!("old status", "tooth")
      sign_in(user)
      
      put "/user-status.json", params: { description: "updated", emoji: "tada" }
      expect(response.status).to eq(200)
      expect(user.reload.user_status.description).to eq("updated")
    end
    
    it "blocks users not in allowed group from updating status" do
      user.set_status!("old status", "tooth")
      sign_in(user)
      
      put "/user-status.json", params: { description: "updated", emoji: "tada" }
      expect(response.status).to eq(403)
      expect(user.reload.user_status.description).to eq("old status")
    end
  end
  
  describe "#clear" do
    it "allows users in allowed group to clear status" do
      allowed_group.add(user)
      user.set_status!("test", "tooth")
      sign_in(user)
      
      delete "/user-status.json"
      expect(response.status).to eq(200)
      expect(user.reload.user_status).to be_nil
    end
    
    it "blocks users not in allowed group from clearing status" do
      user.set_status!("test", "tooth")
      sign_in(user)
      
      delete "/user-status.json"
      expect(response.status).to eq(403)
      expect(user.reload.user_status).to be_present
    end
  end
end
