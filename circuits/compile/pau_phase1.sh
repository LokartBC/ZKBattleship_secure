if test $# -eq 1;then
POWER=$1
else
POWER=12
fi

snarkjs powersoftau new bn128 "$POWER" pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
