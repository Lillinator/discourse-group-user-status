# frozen_string_literal: true

module DiscourseGroupUserStatus
  module UserStatusControllerPatch
    # Override ensure_feature_enabled to add group-based permission checks
    # This runs before set/update/clear actions in UserStatusController
    def ensure_feature_enabled
      # Call parent to check if user_status feature is enabled
      super
      
      # Admins always have permission
      return if current_user.admin?
      
      allowed_group_ids = SiteSetting.user_status_allowed_groups_map
      # If no groups specified, everyone can set status (default behavior)
      return if allowed_group_ids.empty?
      
      # Check if user is member of any allowed group
      unless current_user.in_any_groups?(allowed_group_ids)
        raise Discourse::InvalidAccess.new
      end
    end
  end
end
