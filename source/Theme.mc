import Toybox.Graphics;
import Toybox.Lang;

module Theme {
    const COLOR_PRIMARY_DEFAULT = 0xF5F7FA;
    const COLOR_SECONDARY_DEFAULT = 0xB8C0CC;
    const COLOR_PANEL = 0x101217;
    const COLOR_PANEL_AOD = 0x000000;
    const COLOR_STEPS = 0x00D084;
    const COLOR_HEART = 0xFF4D6D;
    const COLOR_CALORIES = 0xFF8C00;
    const COLOR_WARNING = 0xFF3B30;
    const COLOR_AOD_TEXT = 0x7E8794;

    const RAINBOW_RED = 0xE40303;
    const RAINBOW_ORANGE = 0xFF8C00;
    const RAINBOW_YELLOW = 0xFFED00;
    const RAINBOW_GREEN = 0x008026;
    const RAINBOW_BLUE = 0x24408E;
    const RAINBOW_VIOLET = 0x732982;

    function settingColor(value as Object?) as Number {
        if (value == 2) {
            return 0x56CCF2;
        } else if (value == 3) {
            return 0xFFED88;
        } else if (value == 1) {
            return COLOR_SECONDARY_DEFAULT;
        }

        return COLOR_PRIMARY_DEFAULT;
    }
}

