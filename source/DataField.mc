// vim: syntax=c

using Toybox.WatchUi;
using Toybox.System;
using Toybox.Attention;
using Toybox.Position;

class DataField extends WatchUi.SimpleDataField {
	hidden var recording;
	hidden var threshold;
	hidden var repeat;
	const TH_RESET = 5;
	const REPEAT_RESET = 5;
	const SPEED_TH = 2.5;

	hidden var gps_field;

	function reset() {
		threshold = TH_RESET;
		repeat = REPEAT_RESET;
	}

	function maybe_warn() {
		if (threshold > 0) {
			threshold--;
			return;
		}

		if (repeat == 0) {
			return;
		}
		repeat--;

		if (Attention has :playTone) {
			Attention.playTone(Attention.TONE_LOUD_BEEP);
		}

		if (Attention has :vibrate) {
			var vibrateData = [new Attention.VibeProfile(100, 300)];
			Attention.vibrate(vibrateData);
		}
	}

	function initialize() {
		SimpleDataField.initialize();
		label = "Pause/GPS Warning";

		recording = false;
		reset();

		gps_field = createField(
				"gps_quality", 0,
				FitContributor.DATA_TYPE_UINT8,
				{:mesgType=>FitContributor.MESG_TYPE_RECORD});

	}

	function onTimerStart() {
		recording = true;
		reset();
	}

	function onTimerStop() {
		recording = false;
		reset();
	}

	function onTimerReset() {
		recording = false;
		reset();
	}

	hidden function distance_str(val) {
		if (val < 10000.0) {
			return (val / 1000).format("%0.2f");
		}
		return (val / 1000).format("%0.1f");
	}

	function compute(info) {
		var speed = info.currentSpeed;
		var accuracy = info.currentLocationAccuracy;
		if (speed == null || accuracy == null) {
			return "---";
		}

		if (recording && accuracy < Position.QUALITY_GOOD) {
			maybe_warn();
		} else if (!recording && speed > SPEED_TH) {
			maybe_warn();
		} else {
			reset();
		}

		gps_field.setData(accuracy);

		return (recording ? "R" : "P") +  " s:" +
			speed.format("%0.2f") + " g:" +
			accuracy;
/*
		if (info.elapsedDistance == null) {
			return "0.00";
		}
		return distance_str(info.elapsedDistance);
*/
	}
}
