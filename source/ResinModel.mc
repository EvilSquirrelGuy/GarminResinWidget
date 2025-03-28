/*
 * Copyright (C) 2025- EvilSquirrelGuy. All rights reserved.
 *
 * Licensed under the EvilSquirrelGuy Protective Licence.
 * Personal use and modifications allowed. Redistribution requires full source,
 * a changelog, and clear attribution. No commercial use or patenting.
 *
 * Full licence terms: https://github.com/EvilSquirrelGuy/GarminResinWidget/blob/main/LICENCE.md
 */

using Toybox.Communications as Communications;
using Toybox.Application.Properties as Properties;
using Toybox.Application.Storage as Storage;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Math as Maths;

(:glance)
class ResinData {
  // constant value
  static var TIME_PER_RESIN = 8 * Time.Gregorian.SECONDS_PER_MINUTE; // 8 minutes per resin

  var createdTime;  // createdTime
  var maxResin;  // max_resin
  var fullTime;  // now + resin_recovery_time
  
  function initialize() {
    // set createdTime
    createdTime = Time.now().value();
  }

  function getString() as Lang.String {
    return getCurrentResin().toString() + "/" + maxResin.toString();
  }

  function getRemainingSeconds() {
    // get the remaining seconds
    var remainingSeconds = 0;

    // if fullTime isn't set to 0, calculate difference
    if (fullTime > 0) {
      remainingSeconds = fullTime - Time.now().value();
    }

    // if we calculate as 0, it's full so we don't care
    if (remainingSeconds <= 0) {
      remainingSeconds = 0;
    }

    return remainingSeconds;
  }

  function setFullTimeOffset(offset) {
    if (offset != 0) {
      fullTime = Time.now().value() + offset;
    } else { // it's full, discard
      fullTime = 0;
    }
  }

  function getCurrentResin() {
    var remainingTime = getRemainingSeconds();
    var currResin = 0;

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
      // convert to float cuz otherwise it truncates, and we get inaccurate resin count
      currResin = Maths.floor(maxResin.toFloat() - (remainingTime.toFloat()/TIME_PER_RESIN.toFloat())).toNumber();
    }
    return currResin;
  }

  function getDuration() as Lang.String {
    var remainingSeconds = getRemainingSeconds();

    var abbrDays = WatchUi.loadResource(Rez.Strings.abbr_days);
    var abbrHours = WatchUi.loadResource(Rez.Strings.abbr_hours);
    var abbrMins = WatchUi.loadResource(Rez.Strings.abbr_minutes);
    var abbrSecs = WatchUi.loadResource(Rez.Strings.abbr_seconds);
    var left = WatchUi.loadResource(Rez.Strings.time_left);

    if (remainingSeconds == 0) {
      return "Full";
    }

    var durationString = "";

    if (remainingSeconds > Time.Gregorian.SECONDS_PER_DAY) {
      durationString += (remainingSeconds/(24*60*60)).toNumber().toString() + abbrDays + " ";
    }

    if (remainingSeconds > Time.Gregorian.SECONDS_PER_HOUR) {
      durationString += (remainingSeconds%(24*60*60)/(60*60)).toNumber().toString() + abbrHours + " ";
    }

    if (remainingSeconds > Time.Gregorian.SECONDS_PER_MINUTE) {
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

  hidden var ltoken_v2;
  hidden var ltuid_v2;
  hidden var UID;
  hidden var region;

  var resinData = null;

  var callback = null;

  function initialize(cb) {
    System.println("Initialising ResinModel...");
    callback = cb;
    loadConfigData();
    // update the resin data
    updateResinData();
  }

  function loadConfigData() {
    // logs logs logs
    System.println("Reading data from config file...");
    // load the data
    ltoken_v2 = Properties.getValue("ltoken_v2");
    ltuid_v2 = Properties.getValue("ltuid_v2");
    UID = Properties.getValue("game_uid");
    region = Properties.getValue("region");
  }

  function invalidateCache() {
    // log
    System.println("Invalidating cache...");
    // remove our cached version of the resinData
    resinData = null;
    // invalidate the cache so we don't read from storage
    Storage.setValue("lastCacheTime", -1);
    // call update method
    updateResinData();
  }

  function updateResinData() {
    // updates the resin data

    // get last cache time
    var lastCacheTime = Storage.getValue("lastCacheTime");

    // get the cache invalidation period
    var cacheRetention = Properties.getValue("cache_retention") * Time.Gregorian.SECONDS_PER_MINUTE;

    // get difference
    var diff = -1;
    if (lastCacheTime != null && lastCacheTime != -1) {
      diff = Time.now().value() - lastCacheTime; // diff in seconds
    }

    // check if resin data is still stored
    // only rely on memory data for max 60s
    if (resinData != null && Time.now().value() - resinData.createdTime < 60) {
      System.println(Lang.format("Used in-memory data: $1$; $2$; $3$s", [resinData.getCurrentResin(), resinData.maxResin, resinData.getRemainingSeconds()]));
      callback.invoke(resinData);

    // if we last cached 2h+ ago, load the data from cache, otherwise, fetch it from API again
    } else if (diff > cacheRetention || diff == -1) {
      fetchResinData();
    } else {
      generateResinData();
    }
  }

  function generateResinData() {
    System.println("Generating resin data from cache...");
    // generate resin data from cached values
    var fullTime = Storage.getValue("resinFullTimestamp");
    var maxResin = Storage.getValue("maxResin");
    // time stuff
    var lastCached = Storage.getValue("lastCacheTime");
    var currTime = Time.now().value();

    if (lastCached == null) {
      // assume that if this is null, then the other values aren't set
      System.println("Error: no cached data found!");
      resinData = null;
      return;
    } else if (lastCached == -1) {
      System.println("Error: cache was manually invalidated");
      resinData = null;
      return;
    } else if (currTime - lastCached > 1.5 * maxResin * ResinData.TIME_PER_RESIN) {
      // if the data hasn't been updated in 1,5x resin cycles we give up, since it's very unlikely to be accurate
      System.println("Error: cached data is too old!");
      resinData = null;
      return;
    }

    // var remainingTime = fullTime - currTime;
    // var currResin = 0; // init to 0

    resinData = new ResinData();
    // resinData.currentResin = currResin;
    resinData.maxResin = maxResin;
    resinData.fullTime = fullTime;

    System.println(Lang.format("Calculated cached data: $1$; $2$; $3$s", [resinData.getCurrentResin(), resinData.maxResin, resinData.getRemainingSeconds()]));

    callback.invoke(resinData);
  }

  function fetchResinData() {

    if (!(Toybox has :Communications)) {
      System.println("Error: Communications module unavailable");
      return;
    }
    // censor uid and log that data was read from config, should give format: 74*****07
    var uid_string = UID.toString();
    var censored_uid = "unset";
    if (UID != 0 && UID != null) {
    censored_uid = uid_string.substring(0, 2)
      + (uid_string.length() == 9 ? "*****" : "******")
      + uid_string.substring(-2,null);
    }

    // log data that we have
    System.println("Using stored account data: game_uid=" + censored_uid + "; region=" + (region == null ? "unset" : region));

    // url paramters
    var params = {
      "server" => region,
      "role_id" => UID
    };


    // censor the cookies and log that we have them
    var censored_ltoken_v2 = "unset";
    if (ltoken_v2.length() != 0 && ltoken_v2 != null) {
      censored_ltoken_v2 = ltoken_v2.substring(0,2) + "***...***" + ltoken_v2.substring(-2,null);
    }

    var censored_ltuid_v2 = "unset";
    if (ltuid_v2 != 0) {
      censored_ltuid_v2 = ltuid_v2.toString().substring(0,2) + "*****" + ltuid_v2.toString().substring(-2,null);
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
    System.println("Attempting to recover - trying cached data...");
    generateResinData();
  }

  function handleData(data) {
    //System.println(data);

    // this only runs if we didn't load data from memory
    resinData = new ResinData();

    // resinData.currentResin = data.get("current_resin").toNumber(); // technically we don't need this field
    resinData.maxResin = data.get("max_resin").toNumber();
    resinData.setFullTimeOffset(data.get("resin_recovery_time").toNumber());

    callback.invoke(resinData);

    System.println(Lang.format("Received data from API: $1$; $2$; $3$s", [resinData.getCurrentResin(), resinData.maxResin, resinData.getRemainingSeconds()]));

    // cache data to persistent storage
    Storage.setValue("resinFullTimestamp", resinData.fullTime);
    Storage.setValue("maxResin", resinData.maxResin);
    // set cache time to now so we can invalidate it after some amount of time
    Storage.setValue("lastCacheTime", Time.now().value());
  }
}
