pragma circom 2.0.0;

include "shipHash.circom";
include "../../ZSnarks/circom-circuits/multiplexer.circom";

template BattleShipDrowned() {
    // input ships as a number corresponding to their binary representation on the grid
    // (see XYOShipsToUint to see how to generate these numbers)    
    signal input carrier;
    signal input battleship;
    signal input cruiser;
    signal input submarine;
    signal input destroyer;

    signal input salt; // add salt to the hash to prevent attacker from finding it

    signal input publicShipHash;
    signal input targets; // binary map of past targets as uint (to be generated in javascript)

    signal output out[5]; // binary response to tell the state of each ship, 1 means drowned

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


    // convert inputs to binary arrays
    component num2Bits_1 = Num2Bits(100);
    num2Bits_1.in <== carrier;
    component num2Bits_2 = Num2Bits(100);
    num2Bits_2.in <== battleship;
    component num2Bits_3 = Num2Bits(100);
    num2Bits_3.in <== cruiser;
    component num2Bits_4 = Num2Bits(100);
    num2Bits_4.in <== submarine;
    component num2Bits_5 = Num2Bits(100);
    num2Bits_5.in <== destroyer;
    component num2Bits_6 = Num2Bits(100);
    num2Bits_6.in <== targets;
  

    // for each ship, check if it has been drowned (i.e that all its positions have been hit)
    component escalarProduct_1 = EscalarProduct(100);
    component escalarProduct_2 = EscalarProduct(100);
    component escalarProduct_3 = EscalarProduct(100);
    component escalarProduct_4 = EscalarProduct(100);
    component escalarProduct_5 = EscalarProduct(100);
    for(var i=0; i<100; i++){
        escalarProduct_1.in1[i] <== num2Bits_1.out[i];
        escalarProduct_2.in1[i] <== num2Bits_2.out[i];
        escalarProduct_3.in1[i] <== num2Bits_3.out[i];
        escalarProduct_4.in1[i] <== num2Bits_4.out[i];
        escalarProduct_5.in1[i] <== num2Bits_5.out[i];

        escalarProduct_1.in2[i] <== num2Bits_6.out[i];
        escalarProduct_2.in2[i] <== num2Bits_6.out[i];
        escalarProduct_3.in2[i] <== num2Bits_6.out[i];
        escalarProduct_4.in2[i] <== num2Bits_6.out[i];
        escalarProduct_5.in2[i] <== num2Bits_6.out[i];
    }

    component greaterEqThan_1 = GreaterEqThan(252);
    component greaterEqThan_2 = GreaterEqThan(252);
    component greaterEqThan_3 = GreaterEqThan(252);
    component greaterEqThan_4 = GreaterEqThan(252);
    component greaterEqThan_5 = GreaterEqThan(252);
    
    greaterEqThan_1.in[0] <== escalarProduct_1.out;
    greaterEqThan_1.in[1] <== 5;
    out[0] <== greaterEqThan_1.out;
    greaterEqThan_2.in[0] <== escalarProduct_2.out;
    greaterEqThan_2.in[1] <== 4;
    out[1] <== greaterEqThan_2.out;
    greaterEqThan_3.in[0] <== escalarProduct_3.out;
    greaterEqThan_3.in[1] <== 3;
    out[2] <== greaterEqThan_3.out;
    greaterEqThan_4.in[0] <== escalarProduct_4.out;
    greaterEqThan_4.in[1] <== 3;
    out[3] <== greaterEqThan_4.out;
    greaterEqThan_5.in[0] <== escalarProduct_5.out;
    greaterEqThan_5.in[1] <== 2;
    out[4] <== greaterEqThan_5.out;

}

component main {public [publicShipHash,targets]} = BattleShipDrowned();
