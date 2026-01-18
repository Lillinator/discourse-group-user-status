# frozen_string_literal: true

require 'rails_helper'

describe Jobs::ClearDisallowedUserStatuses do
  fab!(:allowed_group) { Fabricate(:group) }
  fab!(:allowed_user) { Fabricate(:user) }
  fab!(:disallowed_user) { Fabricate(:user) }
  fab!(:admin) { Fabricate(:admin) }
  
  before do
    SiteSetting.enable_user_status = true
    SiteSetting.user_status_allowed_groups = allowed_group.id.to_s
    allowed_group.add(allowed_user)
    
    allowed_user.set_status!("allowed status", "tooth")
    disallowed_user.set_status!("disallowed status", "tooth")
    admin.set_status!("admin status", "tooth")
  end
  
  it "clears statuses for users not in allowed groups" do
    described_class.new.execute({})
    
    expect(allowed_user.reload.user_status).to be_present
    expect(disallowed_user.reload.user_status).to be_nil
    expect(admin.reload.user_status).to be_present
  end
  
  it "preserves statuses when no groups configured" do
    SiteSetting.user_status_allowed_groups = ""
    
    described_class.new.execute({})
    
    expect(allowed_user.reload.user_status).to be_present
    expect(disallowed_user.reload.user_status).to be_present
    expect(admin.reload.user_status).to be_present
  end
  
  it "clears statuses for users in multiple groups when removed from all allowed groups" do
    other_group = Fabricate(:group)
    user_with_multiple_groups = Fabricate(:user)
    other_group.add(user_with_multiple_groups)
    user_with_multiple_groups.set_status!("multi group status", "tooth")
    
    described_class.new.execute({})
    
    expect(user_with_multiple_groups.reload.user_status).to be_nil
  end

  it "runs when a group is removed from the setting" do
    other_group = Fabricate(:group)
    user_in_other_group = Fabricate(:user)
    other_group.add(user_in_other_group)
    user_in_other_group.set_status!("should be cleared", "tooth")
    
    SiteSetting.user_status_allowed_groups = "#{allowed_group.id}|#{other_group.id}"
    SiteSetting.user_status_allowed_groups = allowed_group.id.to_s
    
    expect(user_in_other_group.reload.user_status).to be_nil
    expect(allowed_user.reload.user_status).to be_present
  end

  it "preserves holiday statuses from Calendar plugin" do
    skip "Calendar plugin not installed" unless defined?(DiscourseCalendar)
  
    holiday_emoji = SiteSetting.holiday_status_emoji.presence || "date"
    disallowed_user.set_status!(
      I18n.t("discourse_calendar.holiday_status.description"),
      holiday_emoji,
      1.week.from_now
    )
  
    described_class.new.execute({})
  
    expect(disallowed_user.reload.user_status).to be_present
  end
end
