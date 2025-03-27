/*
 * Copyright (C) 2025- EvilSquirrelGuy. All rights reserved.
 *
 * Licensed under the EvilSquirrelGuy Protective Licence.
 * Personal use and modifications allowed. Redistribution requires full source,
 * a changelog, and clear attribution. No commercial use or patenting.
 *
 * Full licence terms: https://github.com/EvilSquirrelGuy/GarminResinWidget/blob/main/LICENSE.md
 */

import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class ResinWidget extends Application.AppBase {

    hidden var resinModel;
    hidden var resinDelegate;  // update automatically
    hidden var resinView;
    hidden var resinGlanceView;


    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    function onSettingsChanged() as Void {
        var UID = Properties.getValue("game_uid");
        var serverDigit = UID.toString().toCharArray()[0].toString().toNumber();  // get one character
        var region = "os_";

        if (serverDigit == 6) { region = "os_usa"; }  // NA
        else if (serverDigit == 7) { region = "os_euro"; }  // EU
        else if (serverDigit == 8 || (serverDigit == 1 && UID.toString().length() == 10)) { region = "os_asia"; }  // Asia
        else if (serverDigit == 9) { region = "os_cht"; } // SAR

        System.println("Uid begins with " + serverDigit.toString() + ". Setting region to " + region + ".");

        Properties.setValue("region", region);

        resinModel.updateResinData();
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        resinView = new ResinView();
        resinModel = new ResinModel(resinView.method(:onReceive));
        resinDelegate = new ResinDelegate(resinModel);
        return [ resinView , resinDelegate ];
    }

    (:glance)
    function getGlanceView() as [GlanceView] or [GlanceView, GlanceViewDelegate] or Null {
        resinGlanceView = new ResinGlanceView();
        resinModel = new ResinModel(resinGlanceView.method(:onReceive));
        resinDelegate = new ResinDelegate(resinModel);
        return [ resinGlanceView ] ;
    }

    function getGlanceTheme() as AppBase.GlanceTheme {
        return GLANCE_THEME_BLUE;
    }

}

function getApp() as ResinWidget {
    return Application.getApp() as ResinWidget;
}
