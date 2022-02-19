if test $# -ne 1;then
echo "error : takes one argument = circuit name"
exit 1
fi

cd "$1"
snarkjs powersoftau prepare phase2 ../pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup "$1.r1cs" pot12_final.ptau "$1_0000.zkey"
snarkjs zkey contribute "$1_0000.zkey" "$1_0001.zkey" --name="Lokart" -v
snarkjs zkey export verificationkey "$1_0001.zkey" verification_key.json
cd ..