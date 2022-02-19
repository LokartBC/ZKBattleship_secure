pragma circom 2.0.0;

include "./../ZokRates/circom-circuits/mimcsponge.circom";
include "../../ZokRates/circom-circuits/comparators.circom";


function mapShips(carrier, battleship, cruiser, submarine, destroyer){
	var map[100];

	// init array to zeros
	for(var i=0; i<100; i++){
		map[i] = 0;
	}	

	// fill array with ships as ones
	for(var k=0; k<5; k++){
		map[carrier[0]+k*(carrier[2]==1)+10*(carrier[1]+k*(carrier[2]==0))] = 1;
	}
	for(var k=0; k<4; k++){
		map[battleship[0]+k*(battleship[2]==1)+10*(battleship[1]+k*(battleship[2]==0))] = 1;
	}
	for(var k=0; k<3; k++){
		map[cruiser[0]+k*(cruiser[2]==1)+10*(cruiser[1]+k*(cruiser[2]==0))] = 1;
		map[submarine[0]+k*(submarine[2]==1)+10*(submarine[1]+k*(submarine[2]==0))] = 1;
	}
	for(var k=0; k<2; k++){
		map[destroyer[0]+k*(destroyer[2]==1)+10*(destroyer[1]+k*(destroyer[2]==0))] = 1;
	}	

	return map;
}

template ArraySum(N){
	signal input inp[N];
	signal output out;
	var count=0;
	for(var i=0; i<N; i++){
		count += inp[i];
	}
	out <== count;
}

// hashes ship positions + salt number
template ShipHash(CHECK) {

	signal input carrier[3];
	signal input battleship[3];
	signal input cruiser[3];
	signal input submarine[3];
	signal input destroyer[3];
	signal input salt; // add salt to the hash to prevent attacker from finding it
	
	signal output out;

	component arraySum = ArraySum(100);

	component lessThan1 = LessThan(252);
	component lessThan2 = LessThan(252);
	component lessThan3 = LessThan(252);
	component lessThan4 = LessThan(252);
	component lessThan5 = LessThan(252);

	if(CHECK==1){
		// Check ships orientations are valid
		lessThan1.in[0] <== carrier[2];
		lessThan1.in[1] <== 2;
		lessThan1.out === 1;

		lessThan2.in[0] <== battleship[2]; 
		lessThan2.in[1] <== 2;
		lessThan2.out === 1;

		lessThan3.in[0] <== cruiser[2]; 
		lessThan3.in[1] <== 2;
		lessThan3.out === 1;

		lessThan4.in[0] <== submarine[2]; 
		lessThan4.in[1] <== 2;
		lessThan4.out === 1;

		lessThan5.in[0] <== destroyer[2]; 
		lessThan5.in[1] <== 2;
		lessThan5.out === 1;
		
		// Check ships positions are valid (any out of bounds ship would result in an error here)
		var map[100] = mapShips(carrier, battleship, cruiser, submarine, destroyer);
		for(var i=0; i<100; i++){
			arraySum.inp[i] <-- map[i];
		}
		arraySum.out === 17; // ships should occupy a total of 17 spots
	}

	// hash the ship positions with salt
	component mimcSponge = MiMCSponge(2,220,1);
	// encode ship positions in one integer:
	mimcSponge.ins[0] <== carrier[0] + carrier[1] * 16 + carrier[2] * (16**2) + battleship[0] * (16**3) + battleship[1] * (16**4) + battleship[2] * (16**5) + cruiser[0] * (16**6) + cruiser[1] * (16**7) + cruiser[2] * (16**8) + submarine[0] * (16**9) + submarine[1] * (16**10) + submarine[2] * (16**11) + destroyer[0] * (16**12) + destroyer[1] * (16**13) + destroyer[2] * (16**14);
	mimcSponge.ins[1] <== salt;
	mimcSponge.k <== 0;
	out <== mimcSponge.outs[0];	
}

//component main = ShipHash(1);