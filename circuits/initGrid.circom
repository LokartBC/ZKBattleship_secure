pragma circom 2.0.0;

include "./shipHash.circom";


// Verifies validity of the ships' positions and returns the public hash encoding these positions
template InitGrid() {

	// inputs of ships xy positions
	signal input carrier[3];
	signal input battleship[3];
	signal input cruiser[3];
	signal input submarine[3];
	signal input destroyer[3];
	signal input salt; // add salt to the hash to prevent attacker from finding it
	
	signal output out; // ouputs a hash of the verified grid

	// first check the orientations are binary
	carrier[2]*(1-carrier[2]) === 0;
	battleship[2]*(1-battleship[2]) === 0;
	cruiser[2]*(1-cruiser[2]) === 0;
	submarine[2]*(1-submarine[2]) === 0;
	destroyer[2]*(1-destroyer[2]) === 0;

	// then make a binary grid out of the coordinates and check it has correct number of ones
	component mapShips = MapShips();
	component arraySum = ArraySum(100);
	component shipHash = ShipHash();	

    for(var i=0; i<3; i++){
        mapShips.carrier[i] <== carrier[i];
        mapShips.battleship[i] <== battleship[i];
        mapShips.cruiser[i] <== cruiser[i];
        mapShips.submarine[i] <== submarine[i];
        mapShips.destroyer[i] <== destroyer[i];
    }	

	for(var i=0; i<100; i++){
		arraySum.in[i] <== mapShips.out[i];
		shipHash.in[i] <== mapShips.out[i];		
	}
	arraySum.out === 17; // ships should occupy a total of exactly 17 different spots

	// hash the ship positions with salt (also checks that the grid is binary as it should be)
	shipHash.salt <== salt;
	out <== shipHash.out;	
}

component main = InitGrid();