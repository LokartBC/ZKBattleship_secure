pragma circom 2.0.0;

include "shipHash.circom";
include "../../ZSnarks/maci/trees/incrementalQuinTree.circom";

template BattleShipHit() {
    // input ships as a number corresponding to their binary representation on the grid
    signal input carrier;
    signal input battleship;
    signal input cruiser;
    signal input submarine;
    signal input destroyer;

    signal input salt; // add salt to the hash to prevent attacker from finding it

    signal input publicShipHash;
    signal input target[2];

    signal output out; // binary response to tell if a ship is hit

    // hash check 
    component num2Bits = Num2Bits(100);
    num2Bits.in <== carrier + battleship + cruiser + submarine + destroyer;

    // hash the ship positions with salt (also checks that the grid is binary as it should be)
    component shipHash = ShipHash();    
    for(var i=0; i<100; i++){
        shipHash.in[i] <== num2Bits.out[i];     
    }
    shipHash.salt <== salt;
    publicShipHash === shipHash.out;

    // target check (less than 10)
    component lessThan1 = LessThan(252);
    lessThan1.in[0] <== target[0]; 
    lessThan1.in[1] <== 10;
    lessThan1.out === 1;

    component lessThan2 = LessThan(252);
    lessThan2.in[0] <== target[1]; 
    lessThan2.in[1] <== 10;
    lessThan2.out === 1;

    // hit check
    component quinSelector = QuinSelector(100);
    for(var i=0; i<100; i++){
        quinSelector.in[i] <== num2Bits.out[i];     
    }    
    quinSelector.index <== target[0]+10*target[1];
    out <== quinSelector.out;
}

component main {public [publicShipHash,target]} = BattleShipHit();
