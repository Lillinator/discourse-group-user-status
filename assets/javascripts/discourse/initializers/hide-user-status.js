import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "hide-user-status",
  
  initialize() {
    withPluginApi("1.14.0", (api) => {
      // Hide user status option from preferences/account page
      api.modifyClass("controller:preferences/account", {
        pluginId: "discourse-group-user-status",
        
        // Override the getter to check our custom permission
        get canSelectUserStatus() {
          const originalValue = this._super?.(...arguments);
          // Only show if both the original check passes AND user has permission
          return originalValue && this.currentUser?.can_set_user_status !== false;
        }
      });
      
      // Hide "Set status" button from user menu dropdown
      // Uses MutationObserver to handle dynamically loaded content
      const currentUser = api.getCurrentUser();
      if (currentUser?.can_set_user_status === false) {
        const observer = new MutationObserver(() => {
          const statusButton = document.querySelector('.user-menu .set-user-status');
          if (statusButton && statusButton.style.display !== 'none') {
            // Hide the button whenever it appears in the DOM
            statusButton.style.display = 'none';
          }
        });
        
        // Watch the entire document for changes to catch the menu rendering
        observer.observe(document.body, { childList: true, subtree: true });
      }
    });
  }
};
