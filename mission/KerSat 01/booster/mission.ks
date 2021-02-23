@lazyglobal off.
if true and
	require("ascent.ks") and
	require("systems.ks") and
	require("changeOrbit.ks") and
	require("deorbit.ks") and
	require("control.ks") and
	true {
	main().
}
else{
	notify("REBOOTING BOOSTER").
	wait 10.
	reboot.
}


function main {
	core:doaction("Open Terminal", true).

	until phase = 0 {
		if phase = 1 {
			when ship:altitude > 65000 then {
				deployFairings().
			}
			ascent().
			wait 15.
			setPhase(2).
		}
		else if phase = 2 {
			ag1 ON.
			changeOrbit(2834065, 2000000, 0.05).
			setPhase(3).
		}
		else if phase = 3 {
			core:doaction("Close Terminal", true).
			waitForContinue().
			setPhase(4).
		}
		else if phase = 4 {
			deorbit().
			setPhase(0).
		}
	}

	notify("Orders complete").
	core:doaction("Close Terminal", true).
}