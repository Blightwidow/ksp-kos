//ascent.ks
@lazyglobal off.
require("control.ks").

function changeOrbit{
	parameter tApo.
	parameter tPeri is tApo.
	parameter tPrct is 1.
	parameter sBurn is 5.

	local iDPeri is abs(ship:periapsis - tPeri).
	local iDApo is abs(ship:apoapsis - tApo).

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
	notify("Initiate Orbit Update Procedures").
	wait 1.
	eTime().eTime().

	until rm = 0 {
		if rm = 1 {
			if tApo < ship:periapsis {
				addAlarm("Raw",time:seconds + eta:apoapsis - 90, "PERIAPSIS CORRECTION BURN", "KoS generated").
				set rm to 4.
			} else {
				addAlarm("Raw",time:seconds + eta:periapsis - 90, "APOAPSIS CORRECTION BURN", "KoS generated").
				set rm to 2.
			}
		}
		else if rm = 2 {
			if eta:periapsis < sBurn {
				notify("APOAPSIS CORRECTION BURN").
				resetThrottleController().
				set rm to 3.
			}
			if eta:periapsis < 20 {
				useRCS(hWork).
			}
			if ship:apoapsis < tApo {
				set hWork to ship:prograde.
			}
			else {
				set hWork to ship:retrograde.
			}
		}
		else if rm = 3 {
			set tWork to setThrottle(tApo, ship:apoapsis, iDApo).
			if ship:apoapsis < tApo {
				set hWork to ship:prograde.
			}
			else {
				set hWork to ship:retrograde.
			}

			if approx(ship:apoapsis, tApo, tApo*0.01*tPrct) {
				set tWork to 0.
				if (approx(ship:periapsis, tPeri, tPeri*0.01*tPrct)) {
					set rm to 6.
				}
				else {
					addAlarm("Raw",time:seconds + eta:apoapsis - 90, "PERIAPSIS CORRECTION BURN", "KoS generated").
					set rm to 4.
				}
			}
		}
		else if rm = 4 {
			if eta:apoapsis < sBurn {
				notify("PERIAPSIS CORRECTION BURN").
				resetThrottleController().
				set rm to 5.
			}
			if eta:apoapsis < 20 {
				useRCS(hWork).
			}
			if ship:periapsis < tPeri {
				set hWork to ship:prograde.
			}
			else {
				set hWork to ship:retrograde.
			}
		}
		else if rm = 5 {			
			set tWork to setThrottle(tPeri, ship:periapsis, iDPeri).
			if ship:periapsis < tPeri {
				set hWork to ship:prograde.
			}
			else {
				set hWork to ship:retrograde.
			}

			if approx(ship:periapsis, tPeri, tPeri*0.01*tPrct) {
				set tWork to 0.
				if (approx(ship:apoapsis, tApo, tApo*0.01*tPrct)) {
					set rm to 6.
				}
				else {
					addAlarm("Raw",time:seconds + eta:periapsis - 90, "APOAPSIS CORRECTION BURN", "KoS generated").
					set rm to 2.
				}
			}
		}
		else if rm = 6 {
			notify("ORBIT UPDATED").
			set rm to 0.
		}

		checkStage().

		set tLock to tWork.
		set hLock to hWork.

		eTime().
		telemetry(rm).
		print "Orbit Update   " at (1,1).
		print "tApo  : " + round(tApo/1000) + "k " at (1,7).
		print "Actual : " + round(ship:apoapsis/1000) + "k " at (20,7).
		print "tPeri  : " + round(tPeri/1000) + "k " at (1,8).
		print "Actual : " + round(ship:periapsis/1000) + "k " at (20,8).

	}

	rcs off.
	lock throttle to 0.
	lock steering to ship:prograde.
	clearscreen.

	return true.
}