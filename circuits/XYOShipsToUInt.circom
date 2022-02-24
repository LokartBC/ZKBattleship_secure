include "./shipHash.circom";


// this circuit is not meant to produce proofs, rather its only purpose is to compute the uint representations
// of ships XYO positions to be used as private input for battleShipHit and battleShipDrowned
template XYOShipsToUInt(){

	// inputs of ships xy positions
	signal input carrier[3];
	signal input battleship[3];
	signal input cruiser[3];
	signal input submarine[3];
	signal input destroyer[3];

	signal input salt; // not used, just to use the same input.json
	
	// output the uint representation of each boat positions to use later as private input
	// WARNING: these are private and should not be shared !
	signal output carrier_uint;
	signal output battleship_uint;
	signal output cruiser_uint;
	signal output submarine_uint;
	signal output destroyer_uint;

	carrier[2]*(1-carrier[2]) === 0;
	battleship[2]*(1-battleship[2]) === 0;
	cruiser[2]*(1-cruiser[2]) === 0;
	submarine[2]*(1-submarine[2]) === 0;
	destroyer[2]*(1-destroyer[2]) === 0;

	var ships_uint[5] = [0,0,0,0,0];
	for(var k=0; k<5; k++){
		ships_uint[0] += 2**(carrier[0]+k*carrier[2]+10*(carrier[1]+k*(1-carrier[2])));
	}
	for(var k=0; k<4; k++){
		ships_uint[1] += 2**(battleship[0]+k*battleship[2]+10*(battleship[1]+k*(1-battleship[2])));		
	}
	for(var k=0; k<3; k++){
		ships_uint[2] += 2**(cruiser[0]+k*cruiser[2]+10*(cruiser[1]+k*(1-cruiser[2])));
		ships_uint[3] += 2**(submarine[0]+k*submarine[2]+10*(submarine[1]+k*(1-submarine[2])));		
	}
	for(var k=0; k<2; k++){
		ships_uint[4] += 2**(destroyer[0]+k*destroyer[2]+10*(destroyer[1]+k*(1-destroyer[2])));
	}

	carrier_uint <-- ships_uint[0];
	battleship_uint <-- ships_uint[1];
	cruiser_uint <-- ships_uint[2];
	submarine_uint <-- ships_uint[3];
	destroyer_uint <-- ships_uint[4];
}

component main = XYOShipsToUInt();
