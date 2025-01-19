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