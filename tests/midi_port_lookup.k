#include lib/util2.k

function checkport(arr,name,expected) {
	Arraysort = 0
	actual = matchportname(arr,name)
	if ( actual != expected || Arraysort != 0 ) {
		print("FAIL",name,"expected",expected,"got",actual,"Arraysort",Arraysort)
		exit(1)
	}
}

# Exact names must beat earlier substring matches, including numeric prefixes.
ports = [1="loopMIDI Port 10",2="loopMIDI Port 1",3="loopMIDI Port"]
checkport(ports,"loopMIDI Port 1",2)
checkport(ports,"loopMIDI Port",3)
checkport(ports,"loopMIDI Port 10",1)

# Brackets in generated duplicate labels are literal when the name exists.
ports = [1="Keyboard d",2="Keyboard [duplicate 1]",3="Keyboard [duplicate 2]"]
checkport(ports,"Keyboard [duplicate 1]",2)
checkport(ports,"Keyboard [duplicate 2]",3)

# Keep existing partial/regular-expression selection when no exact name exists.
checkport(ports,"Keyboard",1)
checkport(ports,"^Keyboard d",1)
checkport(ports,"Missing",-1)
checkport([],"Missing",-1)
print("MIDI port lookup tests passed.")
exit(0)
