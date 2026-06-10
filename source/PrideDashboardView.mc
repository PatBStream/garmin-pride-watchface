import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class PrideDashboardView extends WatchUi.WatchFace {

    private var _lowPower as Boolean = false;
    private var _activeBackground as BitmapResource?;
    private var _aodBackground as BitmapResource?;

    public function initialize() {
        WatchFace.initialize();
    }

    public function onLayout(dc as Dc) as Void {
        _activeBackground = WatchUi.loadResource(Rez.Drawables.PrideBackgroundActive) as BitmapResource;
        _aodBackground = WatchUi.loadResource(Rez.Drawables.PrideBackgroundAod) as BitmapResource;
    }

    public function onUpdate(dc as Dc) as Void {
        if (_lowPower) {
            drawAod(dc);
        } else {
            drawActive(dc);
        }
    }

    public function onEnterSleep() as Void {
        _lowPower = true;
        WatchUi.requestUpdate();
    }

    public function onExitSleep() as Void {
        _lowPower = false;
        WatchUi.requestUpdate();
    }

    private function sx(dc as Dc, value as Number) as Number {
        return (value * dc.getWidth()) / 320;
    }

    private function sy(dc as Dc, value as Number) as Number {
        return (value * dc.getHeight()) / 360;
    }

    private function scaled(dc as Dc, value as Number) as Number {
        return ((value * dc.getWidth()) / 320 + (value * dc.getHeight()) / 360) / 2;
    }

    private function isLargeDisplay(dc as Dc) as Boolean {
        return dc.getWidth() >= 400;
    }

    private function atLeast(value as Number, floor as Number) as Number {
        return (value < floor) ? floor : value;
    }

    private function shadowOffset(dc as Dc) as Number {
        return atLeast(scaled(dc, 3), 3);
    }

    private function drawShadowedText(dc as Dc, x as Number, y as Number, font as FontType, text as String, justify as Number, color as Number) as Void {
        var shadow = shadowOffset(dc);
        var nearShadow = atLeast(shadow / 2, 2);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + shadow, y + shadow, font, text, justify);
        dc.drawText(x + nearShadow, y + nearShadow, font, text, justify);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, justify);
    }

    private function drawActive(dc as Dc) as Void {
        drawBackground(dc, _activeBackground);
        drawScrims(dc);

        var primary = Theme.settingColor(Application.Properties.getValue("primaryTextColor"));
        var secondary = Theme.settingColor(Application.Properties.getValue("secondaryTextColor"));
        var data = DataModel.current();

        drawTopRow(dc, primary, secondary, data);
        drawTime(dc, primary, false);
        drawRainbowDivider(dc, sy(dc, 198));

        var slot = 0;
        if (boolSetting("showSteps", true)) {
            drawMetricSlot(dc, slot, 0, Format.compactNumber(data.steps), Theme.COLOR_STEPS);
            slot++;
        }
        if (boolSetting("showHeartRate", true)) {
            drawMetricSlot(dc, slot, 1, metricValue(data.heartRate), Theme.COLOR_HEART);
            slot++;
        }
        if (boolSetting("showBattery", true)) {
            drawMetricSlot(dc, slot, 2, metricWithUnit(data.battery, "%"), batteryColor(data.battery));
            slot++;
        }
        if (boolSetting("showCalories", true)) {
            drawMetricSlot(dc, slot, 3, metricValue(data.calories), Theme.COLOR_CALORIES);
        }
    }

    private function drawAod(dc as Dc) as Void {
        drawBackground(dc, _aodBackground);

        var offset = System.getClockTime().min % 5;
        var x = dc.getWidth() / 2;
        var timeY = sy(dc, 126) + offset;
        var dateY = sy(dc, 206) - offset;
        var timeFont = Graphics.FONT_NUMBER_HOT;
        var dateFont = isLargeDisplay(dc) ? Graphics.FONT_MEDIUM : Graphics.FONT_SMALL;

        dc.setColor(Theme.COLOR_AOD_TEXT, Graphics.COLOR_TRANSPARENT);
        drawTimeAt(dc, x, timeY, timeFont, false, true, Theme.COLOR_AOD_TEXT);

        dc.drawText(x, dateY, dateFont, dateString(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawBackground(dc as Dc, bitmap as BitmapResource?) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (bitmap != null) {
            dc.drawBitmap(0, 0, bitmap);
        }
    }

    private function drawScrims(dc as Dc) as Void {
        // Keep the face mostly transparent so the Pride artwork remains visible.
    }

    private function drawTopRow(dc as Dc, primary as Number, secondary as Number, data as DashboardData) as Void {
        if (boolSetting("showDate", true)) {
            var font = isLargeDisplay(dc) ? Graphics.FONT_MEDIUM : Graphics.FONT_SMALL;
            drawShadowedText(dc, sx(dc, 18), sy(dc, 19), font, dateString(), Graphics.TEXT_JUSTIFY_LEFT, secondary);
        }

        // Battery is already shown in the data rows; avoid duplicating it in the top bar.
    }

    private function drawTime(dc as Dc, color as Number, forceNoSeconds as Boolean) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        var seconds = showSeconds() && !forceNoSeconds;
        var font = seconds ? Graphics.FONT_NUMBER_MEDIUM : Graphics.FONT_NUMBER_HOT;
        var y = seconds ? sy(dc, 89) : sy(dc, 92);
        drawTimeAt(dc, dc.getWidth() / 2, y, font, seconds, false, color);
    }

    private function drawTimeAt(dc as Dc, x as Number, y as Number, font as FontType, seconds as Boolean, forceNoSeconds as Boolean, color as Number) as Void {
        var clock = System.getClockTime();
        var hour = clock.hour;
        var suffix = "";

        if (!use24Hour()) {
            suffix = (hour >= 12) ? "PM" : "AM";
            hour = hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }

        var text = hour.toString() + ":" + Format.twoDigits(clock.min);
        if (seconds && !forceNoSeconds) {
            text += ":" + Format.twoDigits(clock.sec);
        }

        drawShadowedText(dc, x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER, color);

        if (!use24Hour() && !forceNoSeconds) {
            var suffixFont = isLargeDisplay(dc) ? Graphics.FONT_SMALL : Graphics.FONT_XTINY;
            var timeWidth = dc.getTextWidthInPixels(text, font);
            var suffixWidth = dc.getTextWidthInPixels(suffix, suffixFont);
            var padding = atLeast(scaled(dc, 6), 6);
            var suffixX = x + (timeWidth / 2) + padding;
            var maxSuffixX = dc.getWidth() - suffixWidth - padding - shadowOffset(dc);

            if (suffixX > maxSuffixX) {
                suffixX = maxSuffixX;
            }

            drawShadowedText(dc, suffixX, y + sy(dc, 38), suffixFont, suffix, Graphics.TEXT_JUSTIFY_LEFT, color);
        }
    }

    private function drawRainbowDivider(dc as Dc, y as Number) as Void {
        var x = sx(dc, 30);
        var w = sx(dc, 43);
        var h = atLeast(sy(dc, 2), 2);
        dc.setColor(Theme.RAINBOW_RED, Theme.RAINBOW_RED);
        dc.fillRectangle(x, y, w, h);
        dc.setColor(Theme.RAINBOW_ORANGE, Theme.RAINBOW_ORANGE);
        dc.fillRectangle(x + w, y, w, h);
        dc.setColor(Theme.RAINBOW_YELLOW, Theme.RAINBOW_YELLOW);
        dc.fillRectangle(x + (w * 2), y, w, h);
        dc.setColor(Theme.RAINBOW_GREEN, Theme.RAINBOW_GREEN);
        dc.fillRectangle(x + (w * 3), y, w, h);
        dc.setColor(Theme.RAINBOW_BLUE, Theme.RAINBOW_BLUE);
        dc.fillRectangle(x + (w * 4), y, w, h);
        dc.setColor(Theme.RAINBOW_VIOLET, Theme.RAINBOW_VIOLET);
        dc.fillRectangle(x + (w * 5), y, w, h);
    }

    private function drawMetric(dc as Dc, cx as Number, cy as Number, radius as Number, icon as Number, value as String, accent as Number) as Void {
        var font = Graphics.FONT_SMALL;
        var shadow = shadowOffset(dc);
        var innerRadius = radius - atLeast(scaled(dc, 5), 5);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx + shadow, cy + shadow, radius);
        dc.drawCircle(cx + shadow, cy + shadow, innerRadius);

        dc.setColor(accent, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, radius);
        dc.drawCircle(cx, cy, innerRadius);

        drawMetricIcon(dc, icon, cx + shadow, cy - sy(dc, 10) + shadow, Graphics.COLOR_BLACK);
        drawMetricIcon(dc, icon, cx, cy - sy(dc, 10), accent);

        drawShadowedText(dc, cx, cy + sy(dc, 7), font, value, Graphics.TEXT_JUSTIFY_CENTER, Theme.COLOR_PRIMARY_DEFAULT);
    }

    private function drawMetricSlot(dc as Dc, slot as Number, icon as Number, value as String, accent as Number) as Void {
        var radius = atLeast(scaled(dc, 31), 31);
        var gap = dc.getWidth() / 4;
        var x = (gap / 2) + (gap * slot);
        var y = sy(dc, 288);

        drawMetric(dc, x, y, radius, icon, value, accent);
    }

    private function drawMetricIcon(dc as Dc, icon as Number, cx as Number, cy as Number, accent as Number) as Void {
        dc.setColor(accent, Graphics.COLOR_TRANSPARENT);

        if (icon == 2) {
            dc.drawRectangle(cx - scaled(dc, 12), cy - scaled(dc, 8), scaled(dc, 21), scaled(dc, 15));
            dc.fillRectangle(cx + scaled(dc, 10), cy - scaled(dc, 4), atLeast(scaled(dc, 4), 4), scaled(dc, 7));
            dc.fillRectangle(cx - scaled(dc, 9), cy - scaled(dc, 5), scaled(dc, 11), scaled(dc, 9));
        } else if (icon == 1) {
            dc.drawLine(cx - scaled(dc, 14), cy, cx - scaled(dc, 8), cy);
            dc.drawLine(cx - scaled(dc, 8), cy, cx - scaled(dc, 4), cy - scaled(dc, 7));
            dc.drawLine(cx - scaled(dc, 4), cy - scaled(dc, 7), cx + scaled(dc, 1), cy + scaled(dc, 8));
            dc.drawLine(cx + scaled(dc, 1), cy + scaled(dc, 8), cx + scaled(dc, 6), cy - scaled(dc, 3));
            dc.drawLine(cx + scaled(dc, 6), cy - scaled(dc, 3), cx + scaled(dc, 14), cy - scaled(dc, 3));
        } else if (icon == 3) {
            dc.drawLine(cx, cy - scaled(dc, 13), cx - scaled(dc, 8), cy - scaled(dc, 3));
            dc.drawLine(cx - scaled(dc, 8), cy - scaled(dc, 3), cx - scaled(dc, 5), cy + scaled(dc, 10));
            dc.drawLine(cx - scaled(dc, 5), cy + scaled(dc, 10), cx + scaled(dc, 7), cy + scaled(dc, 10));
            dc.drawLine(cx + scaled(dc, 7), cy + scaled(dc, 10), cx + scaled(dc, 10), cy - scaled(dc, 3));
            dc.drawLine(cx + scaled(dc, 10), cy - scaled(dc, 3), cx + scaled(dc, 4), cy - scaled(dc, 8));
            dc.drawLine(cx + scaled(dc, 4), cy - scaled(dc, 8), cx, cy - scaled(dc, 13));
        } else {
            dc.fillCircle(cx - scaled(dc, 6), cy - scaled(dc, 10), atLeast(scaled(dc, 4), 4));
            dc.drawLine(cx - scaled(dc, 6), cy - scaled(dc, 6), cx - scaled(dc, 2), cy + scaled(dc, 3));
            dc.drawLine(cx - scaled(dc, 2), cy + scaled(dc, 3), cx - scaled(dc, 10), cy + scaled(dc, 11));
            dc.drawLine(cx - scaled(dc, 2), cy + scaled(dc, 3), cx + scaled(dc, 9), cy + scaled(dc, 10));
            dc.drawLine(cx - scaled(dc, 4), cy - scaled(dc, 1), cx + scaled(dc, 10), cy - scaled(dc, 1));
        }
    }

    private function dateString() as String {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        return Format.DAY_NAMES[now.day_of_week - 1] + " " + Format.MONTH_NAMES[now.month - 1] + " " + Format.twoDigits(now.day);
    }

    private function metricWithUnit(value as Number?, unit as String) as String {
        if (value == null) {
            return "--";
        }
        return value.toString() + unit;
    }

    private function metricValue(value as Number?) as String {
        if (value == null) {
            return "--";
        }
        return value.toString();
    }

    private function batteryColor(value as Number?) as Number {
        if ((value != null) && (value <= 15)) {
            return Theme.COLOR_WARNING;
        }
        return Theme.COLOR_PRIMARY_DEFAULT;
    }

    private function boolSetting(key as String, fallback as Boolean) as Boolean {
        var value = Application.Properties.getValue(key);
        return (value == null) ? fallback : (value as Boolean);
    }

    private function showSeconds() as Boolean {
        return boolSetting("showSeconds", false);
    }

    private function use24Hour() as Boolean {
        return Application.Properties.getValue("timeFormat") == 1;
    }
}
