@lazyglobal off.
if true and
	require("changeOrbit.ks") and
	require("control.ks") and
	require("systems.ks") and
	true {
	main().
}
else{
	notify("REBOOTING").
	wait 10.
	reboot.
}

function main {
	until phase = 0 {
		if phase = 1 {
			waitForContinue().
			setPhase(2).
			clearScreen.
		}
		else if phase = 2 {
			wait 30.
			stage.
			stage.
			deployPanels().
			deployAntenna().
			igniteEngines().
			setPhase(3).
		}
		else if phase = 3 {			
			changeOrbit(2000000, 2000000, 0.01).
			wait 15.
			setPhase(0).
		}
	}

	notify("Orders complete").
	core:doaction("Close Terminal", true).
}