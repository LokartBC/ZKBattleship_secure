include "../../ZSNarks/circom-circuits/bitify.circom";
include "../../ZSNarks/circom-circuits/MiMCSponge.circom";
include "../../ZSNarks/circom-circuits/comparators.circom";

// sum over an array
template ArraySum(N){
	signal input in[N];
	signal output out;
	var count=0;
	for(var i=0; i<N; i++){
		count += in[i];
	}
	out <== count;
}

// map ship positions to a binary array
template MapShips(){
    signal input carrier[3];
    signal input battleship[3];
    signal input cruiser[3];
    signal input submarine[3];
    signal input destroyer[3];

	signal output out[100];

	component arraySum[100];
	component isEq[100][17];

	// for all xy position, check wether it the same as one of the ship positions
	for(var i=0; i<100; i++){
		var mapInt =0;
		arraySum[i] = ArraySum(17);

		for(var k=0; k<17; k++){
			isEq[i][k] = IsEqual();
		}		
		for(var k=0; k<5; k++){
			isEq[i][0+k].in[0] <== carrier[0]+k*carrier[2]+10*(carrier[1]+k*(1-carrier[2]));
			isEq[i][0+k].in[1] <== i;
		}
		for(var k=0; k<4; k++){
			isEq[i][5+k].in[0] <== battleship[0]+k*battleship[2]+10*(battleship[1]+k*(1-battleship[2]));
			isEq[i][5+k].in[1] <== i;
		}
		for(var k=0; k<3; k++){
			isEq[i][9+k].in[0] <== cruiser[0]+k*cruiser[2]+10*(cruiser[1]+k*(1-cruiser[2]));
			isEq[i][9+k].in[1] <== i;
			isEq[i][12+k].in[0] <== submarine[0]+k*submarine[2]+10*(submarine[1]+k*(1-submarine[2]));
			isEq[i][12+k].in[1] <== i;
		}
		for(var k=0; k<2; k++){
			isEq[i][15+k].in[0] <== destroyer[0]+k*destroyer[2]+10*(destroyer[1]+k*(1-destroyer[2]));
			isEq[i][15+k].in[1] <== i;
		}

		for(var k=0; k<17; k++){
			arraySum[i].in[k] <== isEq[i][k].out;
		}		

		out[i] <== arraySum[i].out;
		out[i]*(1-out[i]) === 0;
	}
}

// hash ship positions with private salt
template ShipHash() {
	signal input in[100];
	signal input salt;
	
	signal output out;

	component bits2num = Bits2Num(100);

	// check that in is binary and feed to bit2num
	for(var i=0; i<100; i++){
		in[i]*(1-in[i])===0;
		bits2num.in[i] <== in[i];
	}

	// hash the ship positions with salt
	component mimcSponge = MiMCSponge(2,220,1);

	mimcSponge.ins[0] <== bits2num.out; // encode ship positions grid as one integer with bits2num
	mimcSponge.ins[1] <== salt;
	mimcSponge.k <== 0;
	out <== mimcSponge.outs[0];	
}