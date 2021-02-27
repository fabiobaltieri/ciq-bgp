# Battery, GPS, Pause

This datafield adds a few features to the watch:

Battery:

- shows the battery level
- logs the battery level on the FIT file

GPS

- when the watch is recording, it warns (beep + vibrate up to five times) and indicates if the GPS signal level gets below GOOD
- if location quality is `GOOD` it only displays the battery level
- logs the position quality in the FIT file
- position quality values: 4 = `GOOD`, 3 = `USABLE`, 2 = `POOR`, 1 = `LAST_KNOWN` (see `Position.QUALITY_*` definitions)

Pause Warning

- alerts (beep + vibrate) up to five times if the watch is not recording and speed start to raise, for example if you forget to unpause and start running

https://apps.garmin.com/en-US/apps/0506df9f-7194-4bc3-8d2c-52e705d9a4a4

## License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
