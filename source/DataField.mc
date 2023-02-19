// vim: syntax=c

using Toybox.WatchUi;
using Toybox.System;
using Toybox.Attention;
using Toybox.Position;

class DataField extends WatchUi.SimpleDataField {
	hidden var recording;
	hidden var threshold;
	hidden var repeat;
	hidden var gps_warning;
	const TH_RESET = 5;
	const REPEAT_RESET = 5;
	const SPEED_TH = 2.5;

	hidden var batt_field;
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
		label = "Battery (G/P)";

		gps_warning = Application.getApp().getProperty("gps_warning");

		recording = false;
		reset();

		batt_field = createField(
				"battery", 0,
				FitContributor.DATA_TYPE_UINT8,
				{:mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>"%"});

		gps_field = createField(
				"gps_quality", 1,
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
		if (val < 100000.0) {
			return (val / 1000).format("%0.2f");
		}
		return (val / 1000).format("%0.1f");
	}

	function warn(speed, accuracy) {
		if (speed == null || accuracy == null) {
			return;
		}

		if (recording && accuracy < Position.QUALITY_GOOD) {
			if (gps_warning) {
				maybe_warn();
			}
		} else if (!recording && speed > SPEED_TH) {
			maybe_warn();
		} else {
			reset();
		}

		gps_field.setData(accuracy);
	}

	function compute(info) {
		var stats = System.getSystemStats();
		var batt = Math.round(stats.battery).toNumber();
		var speed = info.currentSpeed;
		var accuracy = info.currentLocationAccuracy;

		//System.println(recording + " " + batt + " " + speed + " " + accuracy);

		warn(speed, accuracy);

		batt_field.setData(batt);

		if (accuracy != null && accuracy < Position.QUALITY_GOOD) {
			return stats.battery.format("%0.1f") + " G" + accuracy;
		} else {
			return stats.battery.format("%0.1f");
		}
	}
}
