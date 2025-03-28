/*
 * Copyright (C) 2025- EvilSquirrelGuy. All rights reserved.
 *
 * Licensed under the EvilSquirrelGuy Protective Licence.
 * Personal use and modifications allowed. Redistribution requires full source,
 * a changelog, and clear attribution. No commercial use or patenting.
 *
 * Full licence terms: https://github.com/EvilSquirrelGuy/GarminResinWidget/blob/main/LICENCE.md
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
        // assume the server based on the uid identifying digit
        var UID = Properties.getValue("game_uid");
        var serverDigit = -1;  // init empty

        if (UID.toString().length() == 9) {
            serverDigit = UID.toString().toCharArray()[0].toString().toNumber();  // get first character
        } else if (UID.toString().length() == 10) {
            // for overflow asia UIDs - like 18xxxxxxxx, assumes that other servers will do something similar
            // when they exceed 100M UIDs
            serverDigit = UID.toString().toCharArray()[1].toString().toNumber();  // get 2nd character
        } else {
            // not provided
            var censored_uid = "null";
            // is it set? censor it
            if (UID != 0 && UID != null) {
                censored_uid = UID.toString().substring(0, 2)
                + "***"
                + UID.toString().substring(-2,null);
            }
            // log it
            System.println("Error - Invalid UID: " + censored_uid);
            resinModel.invalidateCache();
            return;
        }

        var region = "os_";

        // server mappings
        if (serverDigit == 6) { region = "os_usa"; }  // NA
        else if (serverDigit == 7) { region = "os_euro"; }  // EU
        else if (serverDigit == 8) { region = "os_asia"; }  // Asia
        else if (serverDigit == 9) { region = "os_cht"; } // SAR
        else {
            System.println("Error: No server found for digit \"" + serverDigit.toString() + "\"");
            resinModel.invalidateCache();
            return;
        }

        // log
        System.println("Uid begins with " + serverDigit.toString() + ". Setting region to " + region + ".");
        // update properties
        Properties.setValue("region", region);
        
        // trigger config reload
        resinModel.loadConfigData();
        // invalidate the existing cache so we have to refresh
        resinModel.invalidateCache();
        // update resin data with our new data!
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
