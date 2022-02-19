if test $# -ne 1;then
echo "error : takes one argument = circuit name"
exit 1
fi

mkdir $1
cd "$1"
circom "../../$1.circom" --r1cs --wasm --sym --c
cd ..