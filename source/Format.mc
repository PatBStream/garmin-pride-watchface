import Toybox.Lang;

module Format {
    const DAY_NAMES = [ "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT" ];
    const MONTH_NAMES = [ "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC" ];

    function twoDigits(value as Number) as String {
        return value.format("%02d");
    }

    function compactNumber(value as Number?) as String {
        if (value == null) {
            return "--";
        }

        if (value >= 10000) {
            return (value.toFloat() / 1000.0).format("%.1f") + "K";
        }

        return value.toString();
    }
}

