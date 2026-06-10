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
            return (value / 1000).toString() + "K";
        }

        return value.toString();
    }
}
