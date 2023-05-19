#!/bin/bash
set -e

# This script runs a matrix of every valid feature combination
#
# Variables: 
# KAT - Runs the known answer tests


TARGET=$(rustc -vV | sed -n 's|host: ||p')

RUSTFLAGS=${RUSTFLAGS:-""}

# KAT and AVX2 bash variables
if [ -z "$KAT" ]
  then
    echo Not running Known Answer Tests 
  else
  echo Running Known Answer Tests
    RUSTFLAGS+=" --cfg kyber_kat"
fi

# Print Headers
announce(){
  title="#    $1    #"
  edge=$(echo "$title" | sed 's/./#/g')
  echo -e "\n\n$edge"; echo "$title"; echo -e "$edge";
}

##############################################################

start=`date +%s`

announce $TARGET

LEVELS=("kyber512" "kyber768" "kyber1024")
NINES=("")

for level in "${LEVELS[@]}"; do
  for nine in "${NINES[@]}"; do
    for opt in "${OPT[@]}"; do
      name="$level $nine $opt"
      feat=${level:+"$level"}${opt:+",$opt"}${nine:+",$nine"}
      announce "$name"
      RUSTFLAGS=$RUSTFLAGS cargo test --features $feat
      break;
    done
  done
done

end=`date +%s`
runtime=$((end-start))
announce "Test runtime: $runtime seconds"
