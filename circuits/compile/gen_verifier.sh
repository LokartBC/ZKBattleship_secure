if test $# -ne 1;then
echo "error : takes one argument = circuit_name"
exit 1
fi

snarkjs zkey export solidityverifier "$1/$1_0001.zkey" "$1/$1_verifier.sol"