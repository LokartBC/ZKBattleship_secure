pragma circom 2.0.0;

include "shipHash.circom";
include "../../ZSnarks/maci/trees/incrementalQuinTree.circom";

template BattleShipHit() {
    // x,y and orientation (0 if vertical, 1 if horizontal)
    signal input carrier[3];
    signal input battleship[3];
    signal input cruiser[3];
    signal input submarine[3];
    signal input destroyer[3];

    signal input salt; // add salt to the hash to prevent attacker from finding it

    signal input publicShipHash;
    signal input target[2];

    signal output out;

    signal isHit;  

    // hash check (no need to check positions again)
    component mapShips = MapShips();
    component shipHash = ShipHash();    

    for(var i=0; i<3; i++){
        mapShips.carrier[i] <== carrier[i];
        mapShips.battleship[i] <== battleship[i];
        mapShips.cruiser[i] <== cruiser[i];
        mapShips.submarine[i] <== submarine[i];
        mapShips.destroyer[i] <== destroyer[i];
    }   

    // hash the ship positions with salt (also checks that the grid is binary as it should be)
    for(var i=0; i<100; i++){
        shipHash.in[i] <== mapShips.out[i];     
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
        quinSelector.in[i] <== mapShips.out[i];     
    }    
    quinSelector.index <== target[0]+10*target[1];
    out <== quinSelector.out;
}

component main {public [publicShipHash,target]} = BattleShipHit();
