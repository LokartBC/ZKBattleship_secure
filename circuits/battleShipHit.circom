pragma circom 2.0.0;

include "shipHash.circom";

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
    component shipHash = ShipHash(0);
    for(var i=0; i<3; i++){
        shipHash.carrier[i] <== carrier[i];
        shipHash.battleship[i] <== battleship[i];
        shipHash.cruiser[i] <== cruiser[i];
        shipHash.submarine[i] <== submarine[i];
        shipHash.destroyer[i] <== destroyer[i];
    }
    shipHash.salt <== salt;

    publicShipHash === shipHash.out;

    // target check
    component lessThan1 = LessThan(252);
    component lessThan2 = LessThan(252);

    lessThan1.in[0] <== target[0]; 
    lessThan1.in[1] <== 10;
    lessThan1.out === 1;

    lessThan2.in[0] <== target[1]; 
    lessThan2.in[1] <== 10;
    lessThan2.out === 1;    

    // hit check
    var shipMap[100] = mapShips(carrier, battleship, cruiser, submarine, destroyer);

    isHit <-- shipMap[target[0]+10*target[1]];
    assert(isHit<=1);    
    out <== isHit;
}

component main {public [publicShipHash,target]} = BattleShipHit();
