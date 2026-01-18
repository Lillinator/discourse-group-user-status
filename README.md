# Discourse Group User Status

A simple Discourse plugin that allows forum administrators to restric the user status feature to specific user groups.

## Overview

By default, Discourse allows all users to set a custom status with an emoji and description. This plugin gives administrators fine-grained control over which groups can use this feature.

## Features

- **Group-based permissions** - Restrict status setting to selected groups (trust levels, custom groups, or both)
- **Admin override** - Admins always retain status permissions regardless of group selection
- **Automatic cleanup** - Removes statuses from users when they lose permission (via setting changes or group removal)
- **UI integration** - Hides status controls from unauthorized users

## Installation

Follow the [standard plugin installation guide](https://meta.discourse.org/t/install-plugins-on-a-self-hosted-site/19157).

## Configuration

Enable the core user status feature:
   - Navigate to `Admin > All site settings` and search for `user status`
   - Enable `enable_user_status`
   - In the `user_status_allowed_groups` setting, select which groups can set user statuses
   - Leave empty for default behavior (all users can set statuses)

## Behavior

### Permission Changes
When you modify the `user_status_allowed_groups` setting:
- Users who lose permission will have their existing status automatically cleared
- Users who gain permission can immediately set a status

### Group Removal
When a user is removed from an allowed group:
- If they're not in any other allowed groups, their status is cleared
- This applies whether removed via `/admin/groups` or `/admin/users` (or if they leave voluntarily)

### Admin Users
Admins bypass all restrictions and can always set/update their status, even if they're not in any selected group.

### Notifications
This plugin only affects user status, not notification settings:
- The “pause notifications” option in the status modal is a separate feature
- If a user’s status is cleared by this plugin, their paused notifications remain active
- The paused notification indicator stays on their avatar until the duration expires or they manually unpause
- Users who lose status permission keep their notification pause state unchanged

### Discourse Calendar Integration
If you have the [Discourse Calendar plugin](https://github.com/discourse/discourse-calendar) installed:

- Holiday statuses set by the Calendar plugin are preserved by this plugin
- **Rare edge case:** If a user manually overwrites their holiday status, and an admin removes their group from `user_status_allowed_groups` during their scheduled holiday, the manual status will be cleared
- The Calendar plugin automatically resets holiday statuses every 10 minutes, so any cleared status is restored at the next scheduled run
- Users cannot manually set or edit statuses if they're not in an allowed group and have a scheduled holiday status

## Example Use Cases
- Limit to staff members only, category moderators, etc.
- Grant as a perk to supporters or patrons or sellers (custom group)
- Prevent user status abuse by less trusted members
- Let only your admins get coffee breaks! 

---
**Discourse Meta Topic**: https://meta.discourse.org/t/discourse-group-user-status/393748

**Support**: For issues or feature requests, please post in the [Meta topic](https://meta.discourse.org/t/discourse-group-user-status/393748) or start a PR on this repo.  

**To hire me or buy me coffee**: visit me here: [Lilly@Discourse Meta](https://meta.discourse.org/u/Lilly/summary).
