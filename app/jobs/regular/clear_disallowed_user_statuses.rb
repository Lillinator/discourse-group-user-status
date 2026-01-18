# frozen_string_literal: true

module Jobs
  class ClearDisallowedUserStatuses < ::Jobs::Base
    # Clear user statuses for users who are no longer in allowed groups
    # This runs when settings change or users are removed from groups
    
    def execute(args)
      return unless SiteSetting.enable_user_status
      
      # Use group IDs passed from caller, or fall back to current setting
      # Passing IDs directly avoids cache issues with async jobs
      allowed_group_ids = args[:allowed_group_ids] || SiteSetting.user_status_allowed_groups_map
      return if allowed_group_ids.empty?
      
      # Check each user with a status
      UserStatus.includes(:user).find_each do |user_status|
        user = user_status.user
        # Admins always keep their status
        next if user.admin?
        
        # Preserve holiday statuses set by Calendar plugin
        next if is_holiday_status?(user_status)
        
        # Remove status if user is not in any allowed group
        user_status.destroy unless user.in_any_groups?(allowed_group_ids)
      end
    end

    private

    def is_holiday_status?(status)
      # Check if Calendar plugin is installed
      return false unless defined?(DiscourseCalendar)
      
      holiday_emoji = SiteSetting.holiday_status_emoji.presence || "date"
      status.emoji == holiday_emoji &&
        status.description == I18n.t("discourse_calendar.holiday_status.description")
    end
  end
end
