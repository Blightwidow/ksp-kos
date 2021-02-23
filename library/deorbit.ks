//ascent.ks
@lazyglobal off.
require("control.ks").

function deorbit {
	parameter sBurn is 5.
	local rm is 1.

	local tWork is 0.
 	local hWork is ship:facing.
	set tLock to tWork.
	set hLock to hWork. 
	lock throttle to tLock.
	lock steering to hLock.
		
	rcs off.
	sas off.

	clearscreen.
	
	wait 3.
	notify("Initiate Deorbit Procedures").
	wait 1.
	eTime().eTime().

	until rm = 0 {
		if rm = 1 { 
			addAlarm("Raw",time:seconds + eta:apoapsis - 90, "DEORBIT TRAJECTORY BURN", "KoS generated").
			set rm to 2.
		}
		else if rm = 2 {
			set tWork to 0.
			set hWork to ship:retrograde.
			
			if eta:apoapsis < sBurn {
				notify("DEORBIT BURN").
				set rm to 3.
			}
			if eta:apoapsis < 20 {
				useRCS(hWork).
			}
		}
		else if rm = 3 {
			set tWork to 1.
			set hWork to ship:retrograde.

			if ship:periapsis < 0 {
				notify("DEORBIT TRAJECTORY ESTABLISHED").
				set rm to 0.
			}
		}
		set tLock to tWork.
		set hLock to hWork.
		eTime().
		telemetry(rm).
		print "Deorbit   " at (1,1).
	}

	lock throttle to 0.
	lock steering to ship:prograde.
	rcs off.
	clearscreen.

	return true.
}