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

    private function drawActive(dc as Dc) as Void {
        drawBackground(dc, _activeBackground);
        drawScrims(dc);

        var primary = Theme.settingColor(Application.Properties.getValue("primaryTextColor"));
        var secondary = Theme.settingColor(Application.Properties.getValue("secondaryTextColor"));
        var data = DataModel.current();

        drawTopRow(dc, primary, secondary, data);
        drawTime(dc, primary, false);
        drawRainbowDivider(dc, 198);

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
        var timeY = 126 + offset;
        var dateY = 206 - offset;

        dc.setColor(Theme.COLOR_AOD_TEXT, Graphics.COLOR_TRANSPARENT);
        drawTimeAt(dc, x, timeY, Graphics.FONT_NUMBER_HOT, false, true, Theme.COLOR_AOD_TEXT);

        dc.drawText(x, dateY, Graphics.FONT_SMALL, dateString(), Graphics.TEXT_JUSTIFY_CENTER);
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
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.drawText(20, 21, Graphics.FONT_SMALL, dateString(), Graphics.TEXT_JUSTIFY_LEFT);
            dc.setColor(secondary, Graphics.COLOR_TRANSPARENT);
            dc.drawText(18, 19, Graphics.FONT_SMALL, dateString(), Graphics.TEXT_JUSTIFY_LEFT);
        }

        // Battery is already shown in the data rows; avoid duplicating it in the top bar.
    }

    private function drawTime(dc as Dc, color as Number, forceNoSeconds as Boolean) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        var seconds = showSeconds() && !forceNoSeconds;
        var font = Graphics.FONT_NUMBER_MEDIUM;
        var y = seconds ? 89 : 99;
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

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + 2, y + 2, font, text, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);

        if (!use24Hour() && !forceNoSeconds) {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x + 86, y + 35, Graphics.FONT_XTINY, suffix, Graphics.TEXT_JUSTIFY_LEFT);
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x + 84, y + 33, Graphics.FONT_XTINY, suffix, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    private function drawRainbowDivider(dc as Dc, y as Number) as Void {
        var x = 30;
        var w = 43;
        dc.setColor(Theme.RAINBOW_RED, Theme.RAINBOW_RED);
        dc.fillRectangle(x, y, w, 2);
        dc.setColor(Theme.RAINBOW_ORANGE, Theme.RAINBOW_ORANGE);
        dc.fillRectangle(x + w, y, w, 2);
        dc.setColor(Theme.RAINBOW_YELLOW, Theme.RAINBOW_YELLOW);
        dc.fillRectangle(x + (w * 2), y, w, 2);
        dc.setColor(Theme.RAINBOW_GREEN, Theme.RAINBOW_GREEN);
        dc.fillRectangle(x + (w * 3), y, w, 2);
        dc.setColor(Theme.RAINBOW_BLUE, Theme.RAINBOW_BLUE);
        dc.fillRectangle(x + (w * 4), y, w, 2);
        dc.setColor(Theme.RAINBOW_VIOLET, Theme.RAINBOW_VIOLET);
        dc.fillRectangle(x + (w * 5), y, w, 2);
    }

    private function drawMetric(dc as Dc, x as Number, y as Number, width as Number, height as Number, icon as Number, value as String, accent as Number) as Void {
        dc.setColor(accent, accent);
        dc.fillRectangle(x, y + 6, 5, 28);

        drawMetricIcon(dc, icon, x + 29, y + 21, accent);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + width - 6, y + 8, Graphics.FONT_SMALL, value, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(Theme.COLOR_PRIMARY_DEFAULT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + width - 8, y + 6, Graphics.FONT_SMALL, value, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    private function drawMetricSlot(dc as Dc, slot as Number, icon as Number, value as String, accent as Number) as Void {
        if (slot == 0) {
            drawMetric(dc, 18, 226, 134, 40, icon, value, accent);
        } else if (slot == 1) {
            drawMetric(dc, 170, 226, 134, 40, icon, value, accent);
        } else if (slot == 2) {
            drawMetric(dc, 18, 282, 134, 40, icon, value, accent);
        } else if (slot == 3) {
            drawMetric(dc, 170, 282, 134, 40, icon, value, accent);
        }
    }

    private function drawMetricIcon(dc as Dc, icon as Number, cx as Number, cy as Number, accent as Number) as Void {
        dc.setColor(accent, Graphics.COLOR_TRANSPARENT);

        if (icon == 2) {
            dc.drawRectangle(cx - 12, cy - 8, 21, 15);
            dc.fillRectangle(cx + 10, cy - 4, 4, 7);
            dc.fillRectangle(cx - 9, cy - 5, 11, 9);
        } else if (icon == 1) {
            dc.drawLine(cx - 14, cy, cx - 8, cy);
            dc.drawLine(cx - 8, cy, cx - 4, cy - 7);
            dc.drawLine(cx - 4, cy - 7, cx + 1, cy + 8);
            dc.drawLine(cx + 1, cy + 8, cx + 6, cy - 3);
            dc.drawLine(cx + 6, cy - 3, cx + 14, cy - 3);
        } else if (icon == 3) {
            dc.drawLine(cx, cy - 13, cx - 8, cy - 3);
            dc.drawLine(cx - 8, cy - 3, cx - 5, cy + 10);
            dc.drawLine(cx - 5, cy + 10, cx + 7, cy + 10);
            dc.drawLine(cx + 7, cy + 10, cx + 10, cy - 3);
            dc.drawLine(cx + 10, cy - 3, cx + 4, cy - 8);
            dc.drawLine(cx + 4, cy - 8, cx, cy - 13);
        } else {
            dc.fillCircle(cx - 6, cy - 10, 4);
            dc.drawLine(cx - 6, cy - 6, cx - 2, cy + 3);
            dc.drawLine(cx - 2, cy + 3, cx - 10, cy + 11);
            dc.drawLine(cx - 2, cy + 3, cx + 9, cy + 10);
            dc.drawLine(cx - 4, cy - 1, cx + 10, cy - 1);
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
