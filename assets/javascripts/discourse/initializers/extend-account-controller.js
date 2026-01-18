import { apiInitializer } from "discourse/lib/api";
import { alias } from "@ember/object/computed";

// Extend the account preferences controller to respect can_set_user_status
export default apiInitializer("1.14.0", (api) => {
  api.modifyClass("controller:preferences/account", {
    pluginId: "discourse-group-user-status", 

    // Override canSelectUserStatus to use our custom permission check
    // This aliases to the can_set_user_status attribute from CurrentUserSerializer
    canSelectUserStatus: alias("currentUser.can_set_user_status"),
  });
});
