/*
 * Copyright (C) 2025- EvilSquirrelGuy. All rights reserved.
 *
 * Licensed under the EvilSquirrelGuy Protective Licence.
 * Personal use and modifications allowed. Redistribution requires full source,
 * a changelog, and clear attribution. No commercial use or patenting.
 *
 * Full licence terms: https://github.com/EvilSquirrelGuy/GarminResinWidget/blob/main/LICENSE.md
 */

using Toybox.Communications as Communications;
using Toybox.Application.Properties as Properties;
using Toybox.Application.Storage as Storage;
using Toybox.Lang;
using Toybox.Time;

(:glance)
class ResinData {
  var currentResin;  // current_resin
  var maxResin;  // max_resin
  var remainingSeconds;  // resin_recovery_time
  const TIME_PER_RESIN = 8 * Time.Gregorian.SECONDS_PER_MINUTE; // 8 minutes per resin

  function getString() as Lang.String {
    return currentResin.toString() + "/" + maxResin.toString();
  }

  function getDuration() as Lang.String {
    var abbrDays = WatchUi.loadResource(Rez.Strings.abbr_days);
    var abbrHours = WatchUi.loadResource(Rez.Strings.abbr_hours);
    var abbrMins = WatchUi.loadResource(Rez.Strings.abbr_minutes);
    var abbrSecs = WatchUi.loadResource(Rez.Strings.abbr_seconds);
    var left = WatchUi.loadResource(Rez.Strings.time_left);

    if (remainingSeconds == 0) {
      return "Full";
    }

    var durationString = "";

    if (remainingSeconds > 24*60*60) {
      durationString += (remainingSeconds/(24*60*60)).toNumber().toString() + abbrDays + " ";
    }

    if (remainingSeconds > 60*60) {
      durationString += (remainingSeconds%(24*60*60)/(60*60)).toNumber().toString() + abbrHours + " ";
    }

    if (remainingSeconds > 60) {
      durationString += (remainingSeconds%(60*60)/(60)).toNumber().toString() + abbrMins + " ";
    }

    durationString += (remainingSeconds%(60)).toNumber().toString() + abbrSecs + " " + left;

    return durationString;
  }
}

(:glance)
class ResinModel {

  /*  This URL is taken from https://github.com/iseizuu/node-hoyolab/blob/main/src/routes/routes.ts
   *  using variables BBS_API and GENSHIN_RECORD_DAILY_NOTE_API
   *  If this starts raising 404s then those prolly need to be checked...
   */

  const URL = "https://bbs-api-os.hoyolab.com/game_record/genshin/api/dailyNote";

  const ltoken_v2 = Properties.getValue("ltoken_v2");
  const ltuid_v2 = Properties.getValue("ltuid_v2");
  const UID = Properties.getValue("game_uid");
  const region = Properties.getValue("region");

  var resinData = null;

  var callback = null;

  function initialize(cb) {
    System.println("Initialising ResinModel...");
    callback = cb;

    var lastCacheTime = Time.Moment(Storage.getValue("lastCacheTime"));

    // get difference
    var diff = abs(lastCacheTime.compare(Time.Moment(Time.today().value())));

    // check if resin data is still stored
    if (resinData != null) {
      callback(resinData);

    // if we last cached 2h+ ago, load the data from cache, otherwise, fetch it from API again
    } else if (diff > 2 * Time.Gregorian.SECONDS_PER_HOUR) {
      fetchResinData();
    } else {
      generateResinData();
    }

  }

  function generateResinData() {
    System.println("Generating resin data from cache...");
    // generate resin data from cached values
    const fullTime = Storage.getValue("resinFullTimestamp");
    const maxResin = Storage.getValue("maxResin");
    // time stuff
    const lastCached = Storage.getValue("lastCacheTime");
    const currTime = Time.today().value();

    if (lastCacheTime == null) {
      // assume that if this is null, then the other values aren't set
      System.println("Error: no cached data found!");
    } else if (lastCacheTime == -1) {
      System.println("Error: cache was manually invalidated");
    }
    } else if (currTime - lastCached > 1.5 * maxResin * TIME_PER_RESIN) {
      // if the data hasn't been updated in 1,5x resin cycles we give up, since it's very unlikely to be accurate
      System.println("Error: cached data is too old!");
    }

    const remainingTime = currTime - fullTime;
    var currResin = 0; // init to 0

    if (remainingTime <= 0) { // it's full already
      currResin = maxResin;
    } else {
      // calculate current resin
      // i wrote this on 5h of sleep and ungodly amounts of caffeine so the logic might be flawed... oops?
      /*
       * I feel like i need to explain what's going on here or I'll forget so:
       *  (assuming max resin = 200, time per resin = 480s, or 8min)
       * 
       *    If there's 20s left until full, that means we have 199 resin, and 200 in 20s.
       *      Therefore, we floor the result, as we have the same amout of resin as we had time remaining was 480s.
       *    Now extrapolate that to, for example 3600s left. 3600s = 7,5 resin, or rather: 200-7,5 = 192,5. However since
       *    we can't have fractional resin, and it's not generated 193 resin yet, we simply floor the result to get our
       *    current resin count! 
       *
       * And as we all know, that condenses down into a single line of code!
       */
      currResin = maxResin - floor(remainingTime/TIME_PER_RESIN);
    }

    resinData = new ResinData();
    resinData.currentResin = currResin;
    resinData.maxResin = maxResin;
    resinData.remainingSeconds = remainingTime;

    System.println(Lang.format("Calculated cached data: $1$; $2$; $3$s", [resinData.currentResin, resinData.maxResin, resinData.remainingSeconds]));

    callback(resinData);
  }

  function fetchResinData() {

    if (!(Toybox has :Communications)) {
      System.println("Error: Communications module unavailable");
      return;
    }
    // censor uid and log that data was read from config, should give format: 74*****07
    var censored_uid = UID.toString().substring(0, 2) + UID.toString().length()-4 + UID.toString().substring(-2,null);

    // log data that we have
    System.println("Using stored account data: game_uid=" + censored_uid + "; region=" + region);

    // url paramters
    var params = {
      "server" => region,
      "role_id" => UID
    };

    // censor the cookies and log that we have them
    if (ltoken_v2.length != 0) {
      var censored_ltoken_v2 = ltoken_v2.substring(0,1) + "*****" + ltoken_v2.substring(-1,null);
    } else {
      var censored_ltoken_v2 = "unset";
    }

    if (ltuid_v2 != 0) {
      var censored_ltuid_v2 = ltuid_v2.toString().substring(0,1) + "*****" + ltuid_v2.toString().substring(-1,null);
    } else {
      var censored_ltuid_v2 = "unset";
    }
    // log bit
    System.println("Using cookies: ltoken_v2=" + censored_ltoken_v2 + "; ltuid_v2=" + censored_ltuid_v2);

    // parse the actual auth cookies into cookiestring
    var cookieString = "ltoken_v2=" + ltoken_v2 + "; ltuid_v2=" + ltuid_v2.toString() + ";";

    // headers (here, cookies for auth)
    var headers = {
      "Cookie" => cookieString,
    };

    // finalise the options
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :headers => headers
    };

    System.println("Querying API: " + URL);

    Communications.makeWebRequest(URL, params, options, method(:onResponse));

  }

  function onResponse(responseCode as Lang.Number, data as Lang.Dictionary) as Void {
    System.println("Received code " + responseCode.toString() + " from API: ");

    if (responseCode == 200) {
      System.println("Got internal status code " + data.get("retcode").toString());
      if (data.get("retcode") == 0) {
        handleData(data.get("data"));
        return;
      } else {
        System.println("Error - API reported an error: " + data.get("message"));
      }
    } else {
      System.println("Error - Unexpected URL response code: " + responseCode.toString());
    }

    // attempt to generate resin data from cached values
    System.out("Attempting to recover - trying cached data...");
    generateResinData();
  }

  function handleData(data) {
    //System.println(data);

    // this only runs if we didn't load data from memory
    resinData = new ResinData();

    resinData.currentResin = data.get("current_resin").toNumber();
    resinData.maxResin = data.get("max_resin").toNumber();
    resinData.remainingSeconds = data.get("resin_recovery_time").toNumber();

    callback.invoke(resinData);

    System.println(Lang.format("Received data from API: $1$; $2$; $3$s", [resinData.currentResin, resinData.maxResin, resinData.remainingSeconds]));

    // cache data to persistent storage
    Storage.setValue("resinFullTimestamp", Time.Moment(Time.today().value()) + resinData.remainingSeconds);
    Storage.setValue("maxResin", resinData.maxResin)
    // set cache time to now so we can invalidate it after some amount of time
    Storage.setValue("lastCacheTime", Time.Moment(Time.today().value()));
  }
}
