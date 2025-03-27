/*
 * Copyright (C) 2025- EvilSquirrelGuy. All rights reserved.
 *
 * Licensed under the EvilSquirrelGuy Protective Licence.
 * Personal use and modifications allowed. Redistribution requires full source,
 * a changelog, and clear attribution. No commercial use or patenting.
 *
 * Full licence terms: https://github.com/EvilSquirrelGuy/GarminResinWidget/blob/main/LICENSE.md
 */

using Toybox.Communications;
using Toybox.WatchUi;

(:glance)
class ResinDelegate extends WatchUi.BehaviorDelegate {
  var resinModel;

  function initialize(model) {
    resinModel = model;
    WatchUi.BehaviorDelegate.initialize();
  }

  function onSelect() {
    // update data
    resinModel.updateResinData();
    return true;
  }

  function onKey(keyEvent) {
    // pressing menu invalidates the cache and forces an api refresh
    if (keyEvent.getKey() == WatchUi.KEY_MENU) { //} && keyEvent.getType() == WatchUi.CLICK_TYPE_HOLD) {
      resinModel.invalidateCache();
    }
    return true;
  }
}
