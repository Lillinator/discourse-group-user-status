# frozen_string_literal: true

module DiscourseGroupUserStatus
  module CurrentUserSerializerExtension
    # Adds can_set_user_status attribute to the current_user serializer
    # This controls whether the UI displays user status options in the menu
    def can_set_user_status
      # Feature must be enabled site-wide
      return false unless SiteSetting.enable_user_status
      
      # Admins always have permission
      return true if object.admin?
      
      allowed_group_ids = SiteSetting.user_status_allowed_groups_map
      # If no groups specified, everyone can set status (default behavior)
      return true if allowed_group_ids.empty?
      
      # Check if user is member of any allowed group
      object.in_any_groups?(allowed_group_ids)
    end
  end
end
