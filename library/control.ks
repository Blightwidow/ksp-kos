@lazyglobal off.
require("math.ks").
global rcsON is false. 

function idle {
	wait .01.
	eTime().
	telemetry(0).
}

local tBurn is 0.

function setThrottle {
	parameter tVal.
	parameter cVal.
	parameter iDelta.
	parameter tRamp is 4.

	if tBurn = 0 {
		set tBurn to time:seconds.
	}

	return min(min(1, (time:seconds - tBurn)/tRamp), max(0.01, 1 - 1 / exp(5*abs(tVal - cVal)/iDelta))).
}

function resetThrottleController {
	set tBurn to 0.
}

function setThrottleTWR {
	parameter tTWR.
	if ship:availablethrust > 0 {
		return min(1,tTWR * currGrav(ship:altitude) * (ship:mass/ship:availableThrust)).
	}
}

function currGrav {
	parameter atAlt.
	return (constant:G * body:mass)/((atAlt + ship:body:radius)^2).
}

function align {
	parameter tdir.
	local vDiff is vang(ship:facing:vector,tdir:Vector).
	return vDiff.
}

function useRCS {
	parameter hWork is 0.
	parameter vMax is 1.
	parameter vMin is .25.
	if not rcsON and align(hWork) > abs(vMax) {
		rcs on.
		set rcsON to true.
	}
	if rcsON and align(hWork) < abs(vMin) {
		rcs off.
		set rcsON to false.
	}
}

function getPeriod {
	parameter ap.
	parameter pe is ap.
	local sma is (ap + pe + orbit:body:radius * 2)/2.
	return 2*constant:pi*sqrt(sma^3/ship:orbit:body:mu).
}

function checkStage {
	if stageMax - ship:maxthrust > 10 {
		lock throttle to 0.
		stage.
		wait 3.
		lock throttle to tLock.
		set stageMax to ship:maxthrust.
	}
}

function telemetry {
	parameter rm is 0.
	print pMission at (1,0).
	print "Phase: " + phase + " " at (1,2).
	print "rm: " + rm + " " at (12,2).
	print "Status: " + ship:status + "      " at (25,2).
	print "Stage  : " + stage:number + " " at (1,4).
	print "Throttle: " + round(tLock,2) + "      " at (1,5).
	print "Connection to KSC: " at (25,1).
	if homeconnection:isconnected {
    	print "YES" at (44,1).
	}
	else{
		print "NO " at (44,1).
	}
}

function waitForContinue {
	local isEnter is false.
	until isEnter = true {
		print "Waiting for deorbit activiation" at (1,7).
		print "Press ENTER for starting sequence" at (1,8).
		idle().
		local input is terminal:input:getchar().
		if input = terminal:input:enter {
			set isEnter to true.
			return true.
		}
	}
}