import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

(:glance)
class ResinGlanceView extends WatchUi.GlanceView {

    var resinData = null;
    // var resinText = "";

    function initialize() {
        GlanceView.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
       // setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth(), height = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // title
        dc.drawText(0, 8, Graphics.FONT_GLANCE, "Original Resin", Graphics.TEXT_JUSTIFY_LEFT);
        var offset = Graphics.getFontHeight(Graphics.FONT_GLANCE);
        
        // progress bar base
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, height/2, width, 8);

        if (resinData != null) {
            // reset colours
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            // resin count
            dc.drawText(0, (height-16)-offset, Graphics.FONT_GLANCE_NUMBER, resinData.currentResin.toString(), Graphics.TEXT_JUSTIFY_LEFT);
            // max resin
            dc.drawText(width, (height-16)-offset, Graphics.FONT_GLANCE_NUMBER, resinData.maxResin.toString(), Graphics.TEXT_JUSTIFY_RIGHT);

            // colour in progress bar (with a random colour i colour picked from resin)
            dc.setColor(0x4463b7, Graphics.COLOR_TRANSPARENT);

            var pbarWidth = (resinData.currentResin * width) / resinData.maxResin;
            //System.println(Lang.format("$1$/$2$ $3$", [resinData.currentResin, resinData.maxResin, pbarWidth]));

            dc.fillRectangle(0, height/2, pbarWidth, 8);
        } else {
            dc.drawText(0, (height-16)-offset, Graphics.FONT_GLANCE_NUMBER, "No data", Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    function onReceive(data as ResinData) as Void {
        if (data instanceof ResinData) {
            System.println("ResinGlanceView: Received data from ResinModel");
            resinData = data;
            WatchUi.requestUpdate();
        } else {
            System.println("ResinGlanceView: Received invalid data from ResinModel");
        }
    }
}
