#!/bin/bash

exec > >(tee output.txt) 2>&1   # Redirect stdout and stderr to a file and also to the terminal

echo "This goes to terminal and file"

# Trap Ctrl+C and exit the script
trap 'echo "Interrupted! Exiting..."; exit 1' SIGINT

no_of_lists=2000   #  for some reason the last two list 2001 and 2002 have now kernels
dirname="Kernels_Sampling_Study"
dirs=("PbPb_276_PCE_both_3sigma_f0_newparams_0") #  "PbPb_276_PCE_mass_3sigma_f0_newparams_0" "PbPb_276_PCE_both_3sigma_f0_newparams_0"    
data_file="particles_pion.data"
fail_count=0
failed_lists=()

for dir_name in "${dirs[@]}"; do
    subdirname="$dirname/$dir_name"
    mkdir -p "$subdirname"
    for ((i=0; i<no_of_lists; i++)); do
        mkdir -p "$subdirname/list_$i"
        mkdir -p "$subdirname/list_$i/Kernels"
        cp "ParticleDataFiles/$data_file" "$subdirname/list_$i/particles.data"
        rsync -av --ignore-existing tweinrei@files:/lustre/alice/users/tweinrei/Master/FastReso/$subdirname/list_$i/Kj/* "$subdirname/list_$i/Kernels/"
        if [ $? -ne 0 ]; then
            failed_lists+=("$i")
            ((fail_count++))
        fi
        echo "Copied kernels for list $i"
    done
    echo -e "Completed copying for dir $dir_name \n"
    echo "Number of failed copies for dir $dir_name: $fail_count"
    echo "Failed lists: ${failed_lists[*]}"
    failed_lists=()
    fail_count=0
done