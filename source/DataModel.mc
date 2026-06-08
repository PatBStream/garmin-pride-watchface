import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.System;

class DashboardData {
    public var steps as Number?;
    public var stepGoal as Number?;
    public var calories as Number?;
    public var heartRate as Number?;
    public var battery as Number?;
}

module DataModel {

    function current() as DashboardData {
        var data = new DashboardData();
        var info = ActivityMonitor.getInfo();

        if (info has :steps) {
            data.steps = info.steps;
        }

        if (info has :stepGoal) {
            data.stepGoal = info.stepGoal;
        }

        if (info has :calories) {
            data.calories = info.calories;
        }

        data.heartRate = latestHeartRate();

        var stats = System.getSystemStats();
        if (stats != null) {
            data.battery = stats.battery.toNumber();
        }

        return data;
    }

    function latestHeartRate() as Number? {
        var iterator = ActivityMonitor.getHeartRateHistory(1, true);
        var latest = null;

        var sample = iterator.next();
        if ((sample != null) && (sample.heartRate != null) && (sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE)) {
            latest = sample.heartRate;
        }

        return latest;
    }
}
