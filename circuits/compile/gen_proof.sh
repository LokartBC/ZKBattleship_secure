if test $# -ne 2;then
echo "error : takes two argument = circuit_name and json input file "
exit 1
fi

cd "$1"
node "$1_js/generate_witness.js" "$1_js/$1.wasm" "../$2" witness.wtns
snarkjs groth16 prove "$1_0001.zkey" witness.wtns proof.json public.json
cd ..