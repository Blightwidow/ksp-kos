@lazyglobal off.
require("control.ks").
require("navigation.ks").

function escape {
	local rm is 1.

	local tWork is 0.
 	local hWork is ship:prograde.
	set tLock to tWork.
	set hLock to hWork. 
	lock throttle to tLock.
	lock steering to hLock.
	
	rcs off.
	sas off.

	clearscreen.
	
	wait 3.	
	notify("Initiate Escape Procedures").
	wait 1.
	eTime().eTime().

	until rm = 0 {
		if rm = 1 {
			//wait for burn position
			wait 15.
			set rm to 2.
		}
		else if rm = 2 {
			//burn
			wait 15.
			set rm to 3.
		}
		else if rm = 3 {
			//wait edge of SOI
			wait 15.
			set rm to 0.
		}
		eTime().
		telemetry(rm).
		print "Escape" at (1,1).
		print "Time to SOI exit  : " + round(eta:transition) + " " at (1,7).
	}

	clearscreen.
	return true.
}

function waitForWindow {
	local rm is 1.

	local dAngle is 0.
	lock dAngle to getWindowDeltaAngle().
	
	clearscreen.

	wait 3.
	notify("Waiting for transfer window").
	wait 1.
	eTime().eTime().

	until rm = 0 {
		if rm = 1 {
			set warp to 7.
			set rm to 2.
			set mapView to true. 
		}
		else if rm = 2 {
			if approx(180 - abs(dAngle - 180), 0, 1.5) {
            	set rm to 0.
				set warp to 0.
				set mapView to false. 
			}
		}
		eTime().
		telemetry(rm).
		print "Waiting" at (1,1).
		print "Delta Angle  : " + round(dAngle) + " " at (1,8).
	}

	clearscreen.
	return true.
}

local function getWindowDeltaAngle {
	if target:name = "duna" and ship:body:name = "kerbin" {
		return mod(315 - deltaAngle(target, ship:body) + 360, 360).
	}
	
	return 0.
}
