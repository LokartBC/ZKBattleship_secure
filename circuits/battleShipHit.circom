pragma circom 2.0.0;

include "shipHash.circom";
include "../../ZSnarks/circom-circuits/multiplexer.circom";

template BattleShipHit() {
    // input ships as a number corresponding to their binary representation on the grid
    // (see XYOShipsToUint to see how to generate these numbers)
    signal input carrier;
    signal input battleship;
    signal input cruiser;
    signal input submarine;
    signal input destroyer;

    signal input salt; // add salt to the hash to prevent attacker from finding it

    signal input publicShipHash;
    signal input target; // binary map of target as uint (to be generated in javascript)

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

    // hit check
    component num2Bits_target = Num2Bits(100);
    component arraySum = ArraySum(100);
    component escalarProduct = EscalarProduct(100);
    
    num2Bits_target.in <== target;    
    for(var i=0; i<100; i++){
        arraySum.in[i] <== num2Bits_target.out[i];
        escalarProduct.in1[i] <== num2Bits.out[i];
        escalarProduct.in2[i] <== num2Bits_target.out[i];    
    }

    // check that target corresponds to one xy only
    arraySum.out === 1;

    out <== escalarProduct.out;
    out*(1-out) === 0;
}

component main {public [publicShipHash,target]} = BattleShipHit();
