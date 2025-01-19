# Garmin Resin Widget

![Download on Garmin IQ Connect](https://img.shields.io/badge/Download_on-Garmin_IQ_Connect-blue?logo=garmin)
[![Support me on Ko-Fi](https://img.shields.io/badge/Support_me-on_Ko--Fi-ff5e5b?logo=kofi)
](https://ko-fi.com/P5P5198VXT)


A widget for Garmin watches that displays your Genshin Impact resin count!

## Download

You can download the widget off the Garmin App Store at the link below:

[Coming soon™️](#)

## Supported Models

* vívoactive 5
* more soon?

## Setup

This widget directly queries the HoYoLAB API, so you'll need to grab the following things:

* Your HoYoLAB cookies (specifically `ltoken_v2`, and `ltuid_v2`) in order to authenticate
  * [node-hoyolab](https://github.com/iseizuu/node-hoyolab) have a great tutorial on how to do this
* Your Genshin UID for the account you want to query, so the widget knows which account to query

Once you have these, you can configure them in the Garmin Connect IQ App (you'll need to have downloaded the app
from the Garmin App Store for this. Yes, setting it to beta does work, don't worry.) Cookies go in the "Authentication"
group, and your UID goes into "Account".

Make sure to spam the save button a few times since saving the configuration is a bit buggy (at least in my experience).

## Licence

This software is licensed under the GPLv3 with Commons Clause v1. This doesn't make it *truly* open-source, but rather
source-available. Basically I don't want anyone just taking this, uploading the code without changing anything and charging
money for it.

If you like the software enough to want to donate (idk why you'd feel like that, but ig some people like it), I have a Ko-Fi 
page! (see the badge at the top of the page)