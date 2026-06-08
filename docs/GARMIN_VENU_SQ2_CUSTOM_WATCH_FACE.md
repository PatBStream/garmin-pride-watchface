# Custom Garmin Venu Sq 2 Watch Face

This is an overview and build plan for creating a custom watch face for a Garmin Venu Sq 2 with your own data points, typography, colors, layout, and background scene.

## Short Version

There are two practical paths:

1. **Garmin Face It / Connect IQ Store app**
   - Fastest.
   - Good for a photo/background plus a limited set of standard Garmin data fields.
   - Not good if you want full control over layout, fonts, rendering, custom logic, or unusual data combinations.

2. **A real Connect IQ watch face**
   - Best path for your request.
   - Built with Garmin's Connect IQ SDK, Monkey C, resource XML files, bitmaps, fonts, and the Garmin simulator.
   - Can be sideloaded privately to your watch or submitted to the Connect IQ Store.

For a Venu Sq 2, target a **320 x 360 rectangular AMOLED** display. Garmin's compatible device listing shows **Venu Sq 2** and **Venu Sq 2 Music** as Connect IQ API level **5.0** devices.

## What I Can Do For You

Yes, I can build this for you if you provide the design specifics.

I can handle:

- Creating the Connect IQ project structure.
- Targeting Venu Sq 2 / Venu Sq 2 Music.
- Designing the 320 x 360 layout.
- Adding custom colors, fonts, icons, bitmaps, and background art.
- Implementing available Garmin data points.
- Adding configurable settings for colors, field choices, units, and display modes.
- Building and testing in the Garmin simulator.
- Producing a `.prg` file for sideload testing.
- Preparing the project for Connect IQ Store submission if you want it published.

What I would need from you:

- Exact data points you want on screen.
- Priority order for those data points.
- Digital, analog, or hybrid time display.
- 12-hour or 24-hour time.
- Always-on display preference.
- Background scene idea, image, or prompt.
- Font preference or examples.
- Color palette.
- Whether the face is just for you or intended for public Connect IQ Store release.
- Whether you have the standard Venu Sq 2 or Venu Sq 2 Music.

## Important Constraints

Connect IQ watch faces are powerful, but they are not unrestricted native apps.

- Data must come from Garmin's Connect IQ APIs, system complications, activity monitor APIs, sensor APIs, history APIs, or app settings.
- Some desired metrics may be unavailable, delayed, permission-gated, or device-dependent.
- Watch faces run under battery-sensitive update rules.
- Always-on display requires a lower-power layout and conservative drawing.
- Custom fonts are bitmap resources, not normal desktop font rendering.
- Custom font resources are generally single-color masks; multi-color text effects require layering tricks.
- Rich background images consume memory and can hurt performance if not optimized.
- A watch face is different from a Connect IQ data field. A watch face shows everyday watch data; a data field runs inside an activity screen.

## Venu Sq 2 Design Target

Use these as the initial design constraints:

- Device: Garmin Venu Sq 2 / Venu Sq 2 Music
- Display: 320 x 360
- Shape: rectangle
- Technology: AMOLED
- Connect IQ API level: 5.0
- Design implication: black backgrounds and restrained pixel changes can help AMOLED battery life.

The watch face should be designed as a fixed 320 x 360 canvas first. Broader device support can come later, but starting with one device keeps the first version sane.

## Recommended Architecture

A clean first version should have:

- `source/`
  - `App.mc`: application entry point and settings/property access.
  - `View.mc`: watch face drawing and update behavior.
  - Optional helper modules for colors, layout, formatting, and data gathering.
- `resources/`
  - `drawables/`: background images, icons, static bitmap assets.
  - `fonts/`: custom bitmap fonts.
  - `layouts/`: optional layout XML, though hand-drawn graphics are common for watch faces.
  - `strings/`: labels and app metadata.
  - `properties.xml`: persisted defaults.
  - `settings.xml`: user-editable settings exposed in Garmin Connect / Connect IQ.
- `manifest.xml`
  - App type: watch face.
  - Supported products: `venuSq2` / `venuSq2Music` equivalent product IDs from the SDK device list.
  - Permissions only as needed.

## Data Point Planning

Typical watch-face data points to consider:

- Time
- Date
- Day of week
- Battery percentage
- Steps
- Step goal progress
- Heart rate
- Calories
- Distance
- Floors, only if supported by device/API
- Body Battery, if exposed on the target device/API
- Stress, if exposed on the target device/API
- Weather, if available through supported APIs or complications
- Notification count, if available
- Phone connection status
- Bluetooth status
- Alarm status
- Sunrise/sunset, usually depends on location and supported APIs

For each requested data point, confirm:

- Is it available on Venu Sq 2 through Connect IQ?
- Is it live, cached, or historical?
- Does it require permission?
- Is it safe to show in always-on/low-power mode?
- What should display when the value is unavailable?

## Step-by-Step Build

### 1. Install Garmin Developer Tools

Install:

- Garmin Connect IQ SDK Manager.
- Latest Connect IQ SDK.
- Visual Studio Code.
- Garmin Monkey C extension for VS Code.

Garmin's Connect IQ overview page currently lists **Connect IQ 9.1.0** as the latest SDK, updated **May 12, 2026**.

### 2. Create a Developer Key

Connect IQ builds require a developer key for signing.

The typical command-line flow is to generate a key pair and then configure VS Code / the SDK to use it. Keep the private key somewhere stable and backed up. If it is lost, future updates to the same app identity become painful.

### 3. Create a New Watch Face Project

In VS Code with the Monkey C extension:

1. Create a new Connect IQ project.
2. Choose project type: **Watch Face**.
3. Select the Venu Sq 2 target.
4. Set minimum SDK/API based on the features used.
5. Confirm the project builds and runs in the simulator before adding custom logic.

Garmin's "Your First App" documentation specifically walks through creating a watch face project and running/generated builds.

### 4. Define the Display Layout

Start with a 320 x 360 artboard.

Recommended layout process:

1. Sketch the data zones.
2. Reserve a large primary time area.
3. Pick 3 to 6 secondary data slots.
4. Avoid tiny text. The watch is glanceable, not a dashboard monitor.
5. Design a low-power always-on version if desired.
6. Keep background contrast high enough for outdoor readability.

A sensible first layout:

- Top: status row, battery, date, connection.
- Center: time, large custom font.
- Lower middle: primary health metric, such as heart rate or steps.
- Bottom: two or three compact metrics.

### 5. Prepare Background Art

For a Venu Sq 2, create background assets at:

- 320 x 360 for the active face.
- Optional simplified/dim version for always-on mode.

Use PNG assets unless the SDK/project suggests another optimized format. Keep the image compressed and visually simple. A busy background makes the data harder to read and may cost memory.

### 6. Prepare Fonts

Connect IQ custom fonts are resource fonts, commonly generated with BMFont-style tooling and loaded from resources.

Practical font guidance:

- Use custom fonts for the big time display.
- Use Garmin system fonts or simpler custom fonts for small fields.
- Test exact glyph coverage: digits, colon, AM/PM, date text, minus signs, units.
- Keep custom font sizes limited. Multiple large font resources increase memory use.
- For multi-color or outlined text, use layered font resources or draw the same text multiple times with offsets.

### 7. Implement Data Gathering

Implement a data layer that gathers values from the appropriate Connect IQ APIs.

Examples of implementation decisions:

- Time/date: system clock APIs.
- Battery: system stats/device settings APIs.
- Steps/activity metrics: activity monitor/history APIs where available.
- Heart rate: sensor/history APIs or complications, depending on availability and update behavior.
- Weather and richer health stats: prefer complications when supported, or verify target support before committing.

Every field should have fallback rendering:

- `--`
- blank state
- dimmed icon
- last known value with stale marker

### 8. Draw Efficiently

Watch face drawing typically happens in the `View` class.

Good rules:

- Cache loaded resources.
- Avoid allocating heavily in draw/update loops.
- Redraw only what is needed when possible.
- Keep second-by-second updates limited to modes where Garmin allows them.
- Use simple shapes and bitmaps.
- Test both active and low-power behavior.

### 9. Add Settings

Use app properties/settings so you can change behavior from Garmin Connect, Connect IQ Store app, Garmin Express, or an on-device settings flow where supported.

Useful settings:

- Time format: 12/24.
- Theme: dark, light, custom.
- Accent color.
- Data slot 1/2/3 choices.
- Show/hide seconds.
- Always-on simplification.
- Background variant.
- Units or labels.

This keeps one watch face flexible without recompiling for every small preference change.

### 10. Test in the Simulator

Run the face in Garmin's simulator for Venu Sq 2.

Test:

- Active mode.
- Low-power / always-on mode.
- Different times, especially 00:00, 12:00, 23:59.
- Long dates and labels.
- Missing data.
- Low battery.
- Phone connected/disconnected.
- Metric and imperial units if relevant.
- Background contrast in dim mode.

### 11. Sideload to the Watch

For private testing, build a `.prg` file and copy it to the watch.

Garmin's getting-started docs describe copying generated `.PRG` files to the device's `GARMIN/APPS` directory. This is the direct test path before publishing.

Settings for sideloaded apps can be less convenient than store-installed apps, so for polished use it may be worth publishing privately/unlisted if Garmin's workflow supports the desired distribution model.

### 12. Publish, If Desired

If you want the face in the Connect IQ Store:

1. Prepare store metadata.
2. Add screenshots.
3. Confirm supported devices.
4. Verify permissions.
5. Build the release package.
6. Submit for Garmin review.

Public release adds extra work: multi-device support, support contact, privacy policy if relevant, and Garmin review compliance.

## Suggested First Build Scope

For a first version, I would keep it intentionally tight:

- Support only Venu Sq 2 / Venu Sq 2 Music.
- One background scene.
- One custom time font.
- One color theme plus configurable accent.
- Time, date, battery, steps, heart rate, and one optional field.
- Active mode plus a simplified always-on mode.
- No network-dependent data in version 1.

After that works cleanly, expand:

- More fields.
- Multiple themes.
- Multiple backgrounds.
- Store-ready settings.
- Other Garmin device sizes.

## Design Spec Template

Fill this in when ready:

```text
Device:
  - Venu Sq 2 or Venu Sq 2 Music:

Purpose / style:
  - Minimal, dashboard, scenic, retro, aviation, tactical, etc.:

Time:
  - Digital / analog / hybrid:
  - 12h / 24h:
  - Show seconds:

Data fields:
  1.
  2.
  3.
  4.
  5.
  6.

Priority:
  - Must always be visible:
  - Can be small:
  - Can be hidden in always-on mode:

Colors:
  - Background:
  - Primary text:
  - Secondary text:
  - Accent:
  - Warning/low battery:

Fonts:
  - Time font:
  - Small text font:

Background:
  - Existing image path or description:
  - Should data overlay the scene or sit in clear zones:

Settings:
  - Which fields should be configurable:
  - Which colors should be configurable:

Distribution:
  - Private sideload only:
  - Connect IQ Store:
```

## References

- Garmin Connect IQ overview and SDK: https://developer.garmin.com/connect-iq/overview/
- Garmin compatible devices list: https://developer.garmin.com/connect-iq/compatible-devices/
- Garmin Connect IQ app types / watch faces: https://developer.garmin.com/connect-iq/connect-iq-basics/app-types/
- Garmin Your First App guide: https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/
- Garmin Venu Sq 2 owner manual, Connect IQ features: https://www8.garmin.com/manuals/webhelp/GUID-C3225F6F-DF15-4404-9E20-05C4FDCD1207/EN-US/GUID-C3289B5E-1A70-4BB2-A7F0-9B16CF60D75D.html
- Garmin resources documentation: https://developer.garmin.com/connect-iq/core-topics/resources/
- Garmin custom fonts FAQ: https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-use-custom-fonts/
- Garmin app properties/settings: https://developer.garmin.com/connect-iq/core-topics/properties-and-app-settings/
- Garmin complications overview: https://developer.garmin.com/connect-iq/core-topics/complications/
