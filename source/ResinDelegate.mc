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
    resinModel.makeApiCall();
    return true;
  }
}
