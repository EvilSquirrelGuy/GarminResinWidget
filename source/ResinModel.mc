using Toybox.Communications as Communications;
using Toybox.Application.Properties as Properties;
using Toybox.Lang;

(:glance)
class ResinData {
  var currentResin;  // current_resin
  var maxResin;  // max_resin
  var remainingSeconds;  // resin_recovery_time

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
    makeApiCall();
  }

  function makeApiCall() {

    if (!(Toybox has :Communications)) {
      System.println("Communications module unavailable");
      return;
    }
    // url paramters
    var params = {
      "server" => region,
      "role_id" => UID
    };

    var cookieString = "ltoken_v2=" + ltoken_v2 + "; ltuid_v2=" + ltuid_v2.toString() + ";";

    // headers (here, cookies for auth)
    var headers = {
      "Cookie" => cookieString,
    };

    // debug the cookies
    // System.println(headers.get("Cookies"));

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
      } else {
        System.println("Encountered an error while calling API: " + data.get("message"));
      }
    } else {
      System.println("Encountered error while calling API: " + responseCode.toString());
    }
  }

  function handleData(data) {
    //System.println(data);

    if (resinData == null) {
      resinData = new ResinData();
    }

    resinData.currentResin = data.get("current_resin").toNumber();
    resinData.maxResin = data.get("max_resin").toNumber();
    resinData.remainingSeconds = data.get("resin_recovery_time").toNumber();

    callback.invoke(resinData);

    System.println(Lang.format("Extracted data from API: $1$/$2$ $3$s", [resinData.currentResin, resinData.maxResin, resinData.remainingSeconds]));
  }

}