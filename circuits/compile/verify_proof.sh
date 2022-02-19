if test $# -ne 1;then
echo "error : takes one argument = circuit_name "
exit 1
fi

snarkjs groth16 verify "$1/verification_key.json" "$1/public.json" "$1/proof.json"
