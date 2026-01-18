import { acceptance } from "discourse/tests/helpers/qunit-helpers";
import { test } from "qunit";
import { visit } from "@ember/test-helpers";

acceptance("User Status - Group Permissions", function (needs) {
  needs.user({
    groups: [
      { id: 10, name: "trust_level_0" },
      { id: 50, name: "cool_group" },
    ],
  });

  test("when group setting is empty, user can set status", async function (assert) {
    this.siteSettings.enable_user_status = true;
    this.siteSettings.user_status_allowed_groups = "";
    
    await visit("/");
    assert.true(this.currentUser.can_set_user_status, "user should be able to set status");
  });

  test("when user is in an allowed group, user can set status", async function (assert) {
    this.siteSettings.enable_user_status = true;
    this.siteSettings.user_status_allowed_groups = "1|50|3";
    
    await visit("/");
    assert.true(this.currentUser.can_set_user_status, "user should be able to set status");
  });

  test("when user is NOT in an allowed group, user cannot set status", async function (assert) {
    this.siteSettings.enable_user_status = true;
    this.siteSettings.user_status_allowed_groups = "1|2|3";
    
    await visit("/");
    assert.false(this.currentUser.can_set_user_status, "user should NOT be able to set status");
  });

  test("when enable_user_status is false, user cannot set status", async function (assert) {
    this.siteSettings.enable_user_status = false;
    this.siteSettings.user_status_allowed_groups = "1|50|3";
    
    await visit("/");
    assert.false(this.currentUser.can_set_user_status, "user should NOT be able to set status");
  });
  
  test("when user is an admin, user can always set status", async function (assert) {
    this.siteSettings.enable_user_status = true;
    this.siteSettings.user_status_allowed_groups = "1|2|3";
    this.currentUser.set("admin", true);
    
    await visit("/");
    assert.true(this.currentUser.can_set_user_status, "admin should be able to set status");
  });

  // Optional: Test UI element visibility
  test("status button is hidden when user cannot set status", async function (assert) {
    this.siteSettings.enable_user_status = true;
    this.siteSettings.user_status_allowed_groups = "1|2|3";
    
    await visit("/");
    
    const statusButton = document.querySelector('.user-menu .set-user-status');
    if (statusButton) {
      assert.strictEqual(
        statusButton.style.display,
        'none',
        "status button should be hidden"
      );
    } else {
      assert.ok(true, "status button not rendered (also acceptable)");
    }
  });
});
