# Garmin Resin Widget

[![Download on Garmin IQ Connect](https://img.shields.io/badge/Download_on-Garmin_IQ_Connect-blue?logo=garmin)](https://apps.garmin.com/apps/265aed1b-d72b-484b-8baf-c09b00e57f24?tid=0)
[![Support me on Ko-Fi](https://img.shields.io/badge/Support_me-on_Ko--Fi-ff5e5b?logo=kofi)](https://ko-fi.com/P5P5198VXT)


A widget for Garmin watches that displays your Genshin Impact resin count!

## Download

You can download the widget off the Garmin App Store at the link below:

[Download here!](https://apps.garmin.com/apps/265aed1b-d72b-484b-8baf-c09b00e57f24?tid=0)

*Now available in the EU/EEA! 🎉*

## Supported Models

* vívoactive 5
* Forerunner 265/265S
* Venu 2/2+/2S
* Venu 3/3S

## Usage

After setting up, you can refresh the data by tapping the screen (or start/stop button).

You can also force an online refresh (cache invalidation) by either pressing and holding the screen, or holding the back button.

Due to limited testing ability, the above may not work for all models.

Warning! – After invalidating the cache, you will *not be able to* see any resin data until the watch is able to connect to the internet again! Don't do it when you're offline :)

You can configure the cache retention duration in advanced settings.

## Setup

This widget directly queries the HoYoLAB API, so you'll need to grab the following things:

* Your HoYoLAB cookies (specifically `ltoken_v2`, and `ltuid_v2`) in order to authenticate
  * [node-hoyolab](https://github.com/iseizuu/node-hoyolab) have a great tutorial on how to do this
* Your Genshin UID for the account you want to query, so the widget knows which account to query

Once you have these, you can configure them in the Garmin Connect IQ App (you'll need to have downloaded the app
from the Garmin App Store for this. Yes, setting it to beta does work, don't worry.) Cookies go in the "Authentication"
group, and your UID goes into "Account".

The resin should update as soon as you save the config now. The previous behaviour was caused by a bug where updating the config wouldn't actually be reflected in the object responsible for querying resin data, this is fixed in v0.2.1.

## Security & Privacy

In order to be able to access your Genshin data, this app needs your HoYoLAB auth tokens. Naturally, you may be weary of giving a random app
your authentication tokens, since some of you have, no doubt, spent 100s or 1000s on this game ;)

The token is only stored __on your device__, and is only sent to the **Official HoYoLAB API** endpoints. There are no middlemen, no catches,
nothing! I wouldn't want my account data stolen either. You can review [source/ResinModel.mc](source/ResinModel.mc) to see exactly what happens
to the token with web requests.

## Bug Reporting

If you encounter a bug in the app, please follow these steps:

1. Ensure that you're running on the latest version of the app.

2. Ensure that you're able to reproduce the bug on this version.

3. Open an bug report on the GitHub bug tracker (can be found by clicking "Source code").

You can also use the GitHub for any feature requests you may have for the app!

## FAQ & Known Issues

The timer doesn't update itself every second!
> *I tried to fix this in v0.2.0, but implementing this might require some major internal structure changes.*

I've entered my account details but the resin counter is still showing No Data!
> *This was fixed in v0.2.1 – update the app. If you're still getting it in the latest version, make sure all your account details are entered correctly without any spaces! If it still doesn't work, please open an issue on the bug tracker.*

The widget suddenly stopped displaying my resin count!
> *This is likely intentional. Make sure your watch has internet access and try again! The widget will stop displaying data if it's been unable to get data from the HoYoLAB API for over 39 hours (1,5x resin refill time). This can also happen if you manually invalidate the cache.*

The app isn't localised for my language!
> *i18n\* is planned for a future release, but getting language support relies on people to volunteer and translate the strings. If you want to help translate the project, see the GitHub for instructions.*
<sub>*i18n stands for internationalisation</sub>

## Contributing

As this is just a small hobby project of mine, I'm not really looking for help in the core functionality (unless you happen to
be able to solve a bug faster than I can). The main ways you can help are by creating bug reports, feature requests, and (when
the time comes) translations!

Also if you really like the project, consider starring it on GitHub, or writing a quick review on the Garmin Connect IQ store
so more people can access their resin count from their wrist!

## Licence

This software is licensed under the EvilSquirrelGuy Protective Licence, since it's a non-standard licence, here's a little TL;DR of what you can and
can't do with the software:

- **Personal use only** – No commercial use allowed.  
- **No patents** – You cannot file patents based on this software.  
- **No unmodified binaries** – You cannot distribute binaries unless the source has been modified.  
- **Modifications must be open** – If you share modified versions, you must provide full source code and a changelog.  
- **Clear attribution required** – Must credit the original author in a visible and accessible location.  
- **Licence must be included** – Any distributed source code or binaries must include or link to this licence.  
- **No warranties** – The software is provided "as is" with no guarantees.  

If you like the software enough to want to donate (idk why you'd feel like that, but ig some people like it), I have a Ko-Fi 
page! (see the badge at the top of the page)
