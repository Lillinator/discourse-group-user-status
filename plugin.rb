# frozen_string_literal: true

# name: discourse-group-user-status
# about: Restricts the ability to set a user status to members of specific groups.
# version: 0.1
# authors: Lilly
# url: https://github.com/lilly/discourse-group-user-status

after_initialize do
  require_relative "lib/user_status_controller_patch"
  require_relative "app/jobs/regular/clear_disallowed_user_statuses"

  # Patch the UserStatusController to add permission checks
  require_dependency "user_status_controller"
  UserStatusController.prepend(DiscourseGroupUserStatus::UserStatusControllerPatch)
  
  # Add can_set_user_status flag to current_user serializer
  # This controls whether the UI shows the status option
  add_to_serializer(:current_user, :can_set_user_status) do
    return false unless SiteSetting.enable_user_status
    return true if object.admin?
    
    allowed_group_ids = SiteSetting.user_status_allowed_groups_map
    # If no groups specified, everyone can set status
    return true if allowed_group_ids.empty?
    
    # Check if user is in any of the allowed groups
    object.in_any_groups?(allowed_group_ids)
  end

  # When the setting changes, clear statuses for users no longer in allowed groups
  # Pass group IDs directly to avoid reading stale cached values in async job
  DiscourseEvent.on(:site_setting_changed) do |setting_name, old_value, new_value|
    if setting_name == :user_status_allowed_groups && old_value != new_value
      new_group_ids = new_value.to_s.split('|').map(&:to_i).compact
      Jobs.enqueue(:clear_disallowed_user_statuses, allowed_group_ids: new_group_ids)
    end
  end
  
  # When a user is removed from an allowed group, check if they should keep their status
  DiscourseEvent.on(:user_removed_from_group) do |user, group|
    allowed_group_ids = SiteSetting.user_status_allowed_groups_map
    if allowed_group_ids.include?(group.id)
      Jobs.enqueue(:clear_disallowed_user_statuses)
    end
  end
end
