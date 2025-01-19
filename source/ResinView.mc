import Toybox.Graphics;
import Toybox.WatchUi;

class ResinView extends WatchUi.View {

    hidden var appTitle;
    hidden var resinString;
    hidden var resinDuration;
    hidden var resinIcon;

    var resinData = null;

    function initialize() {
        appTitle = WatchUi.loadResource(Rez.Strings.appGlanceTitle);
        resinIcon = WatchUi.loadResource(Rez.Drawables.resin_192_dark);
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        //setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth(), height = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        dc.drawBitmap((width-192)/2, height*0.1, resinIcon);

        if (resinData != null) {

            dc.drawText(width/2, (0.1*height + 192 + 8), Graphics.FONT_SYSTEM_MEDIUM, resinData.getString(), Graphics.TEXT_JUSTIFY_CENTER);

            dc.drawText(width/2, 0.75*height, Graphics.FONT_SYSTEM_XTINY, resinData.getDuration(), Graphics.TEXT_JUSTIFY_CENTER);
            
            dc.setPenWidth(6);
            dc.setColor(0x4463b7, Graphics.COLOR_TRANSPARENT);

            drawRadial(dc, 0, (360*resinData.currentResin)/resinData.maxResin);
            
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);

            dc.drawText(width/2, 0.75*height, Graphics.FONT_SYSTEM_XTINY, "No data", Graphics.TEXT_JUSTIFY_CENTER);
        }

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    function drawRadial(dc as Dc, arcStart, arcEnd) {
        /*
        Draw an arc.
            0 degrees: 3 o'clock position.
            90 degrees: 12 o'clock position.
            180 degrees: 9 o'clock position.
            270 degrees: 6 o'clock position.
        What we want:
            0deg = 12 = 90
            90deg = 3 = 0
            180deg = 6 = 270
            270deg = 9 = 360
        */
        var width = dc.getWidth(), height = dc.getHeight();

        arcStart = (90-arcStart) % 360;
        arcEnd = (90-arcEnd) % 360;

        dc.drawArc(width/2, height/2, height/2, Graphics.ARC_CLOCKWISE, arcStart, arcEnd);
        dc.drawArc((width/2)-1, height/2, height/2, Graphics.ARC_CLOCKWISE, arcStart, arcEnd);
        dc.drawArc(width/2, (height/2)-1, height/2, Graphics.ARC_CLOCKWISE, arcStart, arcEnd);
        dc.drawArc((width/2)-1, (height/2)-1, height/2, Graphics.ARC_CLOCKWISE, arcStart, arcEnd);
    }

    // callback function for receiving resin data
    function onReceive(data) {
        resinData = data;
        WatchUi.requestUpdate();
    }

}
