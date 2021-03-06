//ascent.ks
@lazyglobal off.
require("control.ks").

function ascent{
	parameter tHeading is 90.
	parameter tApo is 100000.
	parameter ApoETA is 60.
	parameter sBurn is 5.
	parameter mPitchAlt is tApo * .8. 

	local rm is 1.
	local mPitch is 0.
	local pidAlt is 60000. 
	local kP1 is 0.05.	
	local kI1 is 0.6.	
	local kD1 is 0.05. // 0.001
	local aPID is pidloop(kP1,kI1,kD1,0,1).
	set aPID:setpoint to 200.
	local iPitch is 90.
	local iDPeri is 0.
	local tPitch is iPitch.
	local tLaunch is 0.
	local tPrd is getPeriod(tApo).
	local fIg is true. 
	local speedLimit is 0.

	local tWork is 0.
 	local hWork is ship:facing.
	set tLock to tWork.
	set hLock to hWork. 
	lock throttle to tLock.
	lock steering to hLock.
	local tTWR is 1.5. 
		
	rcs off.
	sas off.

	clearscreen.
	local tCD is 10.
	
	wait 3.
	notify("Initiate Ascent Procedures").
	wait 1.
	eTime().eTime().

	until rm = 0 {
		if rm = 1 { 
			if tCD > 0 {
				notify("COUNTDOWN INITIATED: T - " + round(tCD)).
				if fIg and tCD < 1{
					igniteEngines(1).
					set fIg to false.
				}
				set tCD to tCD - tElapsed.
			}
			else {
				stage.
				set hWork to ship:facing.
				set tWork to aPID:update(time:seconds,verticalspeed).
				set stageMax to ship:maxthrust.
				set rm to 2.
				notify("LAUNCH").
			}
		}
		else if rm = 2 {
			useRCS(hWork).
			set tWork to setThrottleTWR(tTWR).

			if ship:altitude > 8000 {
				set kP1 to 0.156.
				set kI1 to 0.101.	
				set kD1 to 0.060.	
				set aPID to pidloop(kP1,kI1,kD1,0,1).
				set aPID:setpoint to ApoETA.
				set rm to 3.
			}
			else if verticalspeed > 50 {      
				set tPitch to min(iPitch,max(mPitch,90*(1 - alt:radar/mPitchAlt))).                    
				set hWork to heading(tHeading,tPitch).
			}
			else if verticalspeed > 20 {
				set hWork to heading(tHeading,90).
			}.
		}
		else if rm = 3 {
			useRCS(hWork).
			set tPitch to min(iPitch,max(mPitch,90 * (1 - alt:radar/mPitchAlt))).
			set hWork to heading(tHeading,tPitch). 
			
			if ship:apoapsis > tApo {
				notify("COAST TO APOAPSIS").			
				set rm to 4.
				set tWork to 0.
				set hWork to ship:prograde.
				addAlarm("Raw",time:seconds + eta:apoapsis - 90, "CIRCULARIZATION BURN", "KoS generated").
			}
			else {
				if approx(ship:apoapsis,tApo,tApo * .03) and ApoETA > 10{
					set ApoETA to ApoETA - tElapsed/3.
					set aPID:setpoint to ApoETA.
				}
				set tWork to max(.01,aPID:update(time:seconds,eta:apoapsis)).	
			}
		}
		else if rm = 4 {
			set tWork to 0.
			set hWork to ship:prograde.

			if eta:apoapsis < sBurn {
				notify("CIRCULARIZATION BURN").
				resetThrottleController().
				set iDPeri to abs(ship:apoapsis - ship:periapsis).
				set rm to 5.
			}
			if eta:apoapsis < 20 {
				useRCS(hWork).
			}
		}
		else if rm = 5 {
			set tWork to setThrottle(ship:apoapsis, ship:periapsis, iDPeri).
			set hWork to ship:prograde.

			if ship:orbit:period > tPrd {
				notify("ORBIT ESTABLISHED").
				set tWork to 0.
				set tCD to 30.
				set rm to 0.
			}
		}

		if checkAbort(rm) {
			return false.
		}
		checkStage().

		set tLock to tWork.
		set hLock to hWork.

		eTime().
		telemetry(rm).
		print "Ascent   " at (1,1).
		print "tPitch  : " + round(tPitch) + " " at (1,7).
		print "Actual : " + round(90-(vang(ship:facing:vector,ship:up:Vector))) + "   " at (15,7).

	}

	rcs off.
	lock throttle to 0.
	lock steering to ship:prograde.
	clearscreen.

	return true.
}

function checkAbort {
	parameter rm.
	if rm > 1 and verticalspeed < -50 and
		ship:altitude < 65000 and 
		ship:periapsis < 0{
		notify("ABNORMAL PARAMETERS DETECTED",red).
		notify("ASCENT ABORTED",red).
		return true.
	}
	else {
		return false.
	}
}