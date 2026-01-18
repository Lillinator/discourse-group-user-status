# frozen_string_literal: true

require 'rails_helper'

describe CurrentUserSerializer do
  fab!(:user) { Fabricate(:user) }
  fab!(:allowed_group) { Fabricate(:group) }
  fab!(:admin) { Fabricate(:admin) }
  
  before do
    SiteSetting.enable_user_status = true
    SiteSetting.user_status_allowed_groups = allowed_group.id.to_s
  end
  
  it "returns true for users in allowed group" do
    allowed_group.add(user)
    serializer = CurrentUserSerializer.new(user, scope: Guardian.new(user), root: false)
    
    expect(serializer.can_set_user_status).to eq(true)
  end
  
  it "returns false for users not in allowed group" do
    serializer = CurrentUserSerializer.new(user, scope: Guardian.new(user), root: false)
    
    expect(serializer.can_set_user_status).to eq(false)
  end
  
  it "returns true for admins regardless of group membership" do
    serializer = CurrentUserSerializer.new(admin, scope: Guardian.new(admin), root: false)
    
    expect(serializer.can_set_user_status).to eq(true)
  end
  
  it "returns true for all users when no groups configured" do
    SiteSetting.user_status_allowed_groups = ""
    serializer = CurrentUserSerializer.new(user, scope: Guardian.new(user), root: false)
    
    expect(serializer.can_set_user_status).to eq(true)
  end
  
  it "returns false when enable_user_status is disabled" do
    SiteSetting.enable_user_status = false
    allowed_group.add(user)
    serializer = CurrentUserSerializer.new(user, scope: Guardian.new(user), root: false)
    
    expect(serializer.can_set_user_status).to eq(false)
  end
end
