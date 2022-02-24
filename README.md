# ZKBattleship secure

A secure and complete Zero Knowledge Proof Battleship game. The circuits can proove:
1. that a grid is valid
2. wether a target hits a ship 
3. which ships where drowned by the past series or targets

Circuit implementations in [circom](https://github.com/iden3/circom) (which can then be used with [snarkjs](https://github.com/iden3/snarkjs)).  

License: Creative Commons

## Prerequisite

[circom installation](https://docs.circom.io/getting-started/installation/)

## Structure

`circuits/` main folder holds the implementation of the circuits  
`circuits/compile/` subfolder contains shell scripts to generate circuits and proofs  
`circuits/input/` subfolder contains inputs used for testing  

## Build circuits

```bash
cd circuits/compile

# make power of tau ceremony (phase 1) once for the project, default is power=12, use power=13 here
./pau_phase1 $power
# compile circuit, example circuitName = shipHash
./compile_circuit.sh circuitName
# make power of tau ceremony (phase 2) once for each circuit
./pau_phase2 circuitName
# generate proof 
./gen_proof circuitName input.json
# verify proof 
./verify_proof circuitName
# generate verifiere.sol
./gen_verifier circuitName

```

## Use circuits

#### initGrid.circom

Checks the positions of the ships are okay (no ships out of bounds or colliding). It generates a hash that should be shared with opponent to initiate a game and proove in the next steps that the ship positions stay the same.

inputs:
- The 5 ships xyo coordinates (0<= x <= 9, 0<= x <= 9, 0<= orientation <= 1)
- a private (random) salt number to make hash not findable

output:
- the hash (as uint) corresponding to the binary map (with salt) of the ships on the grid (1 where ships are and 0 elsewhere)

#### battleShipHit.circom
inputs:
- The 5 ships positions as uints (the uint encode the binary positions on the grid, see XYOShipsToUint.circom to know how to generate them)
- The private salt
- The public hash of the ships positions
- The target, encoded as uint (the uint encodes the binary position on the grid, one and only one xy is 1 and the rest are zeros)

output:
- Wether target has hit a ship (any of them) or not (boolean value)

#### battleShipDrowned.circom
inputs:
- The 5 ships positions as uints (the uint encode the binary positions on the grid, see XYOShipsToUint.circom to know how to generate them)
- The private salt
- The public hash of the ships positions
- All the past target positions, encoded as uint (the uint encodes the binary position of all past targets on the grid)

outputs:
- 5 booleans: wether each ship is drowned or not

## Test circuits

Inputs are provided as test examples.

initGrid:
- *initGrid_packed.json* corresponds to all ships packed vertically in top left corner (working input for initGrid)
- *initGrid_packed_wrong.json* has 2 ships overlapping and will not work (wrong input for initGrid)
- *initGrid_packed_wrong2.json* has a ship out of bounds and will not work (wrong input for initGrid)

battleShipHit:
- *battleShipHit_packed.json* corresponds to the ship positions provided in initGrid_packed.json, with a target hitting the first ship (output is thus 1)
- battleShipHit_packed_miss is the same *battleShipHit_packed.json* but its target misses the ship (output is thus 0)
- battleShipHit_packed_wrongTarget is the same as *battleShipHit_packed.json* but the target uint encodes 2 target positions (thus the program raises an error)

battleShipDrowned:
- *battleShipDrowned_destroyer.json* is the same as *battleShipHit_packed.json* with a history of 2 past target that drown the destroyer
- *battleShipDrowned_destroyer.json* is the same as battleShipHit_packed.json with a history of 5 past target that drown the destroyer ass well as the submarine

