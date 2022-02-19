# zkbattleship-

A Zero Knowledge Proof Battleship game

License ?

Circuit implementations in [circom](https://github.com/iden3/circom) (which can then be used with [snarkjs](https://github.com/iden3/snarkjs)).

## Prerequisite

[circom](https://docs.circom.io/getting-started/installation/)

## Structure

`circuit` subfolder holds the implementation for [circom](https://github.com/iden3/circom) respectively.
`contracts` subfolder contains smart contracts

## Build circuits

```bash
cd circuits/compile

# make power of tau ceremony (phase 1) once for the project, default is power=12
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
