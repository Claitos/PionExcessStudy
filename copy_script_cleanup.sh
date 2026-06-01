#!/bin/bash

exec > >(tee output.txt) 2>&1   # Redirect stdout and stderr to a file and also to the terminal

echo "This goes to terminal and file"

# Trap Ctrl+C and exit the script
trap 'echo "Interrupted! Exiting..."; exit 1' SIGINT

no_of_lists=2000   #  for some reason the last two list 2001 and 2002 have now kernels
dirname="Kernels_Sampling_Study"
dirs=("PbPb_276_PCE_br_3sigma_f0_newparams_0") #  "PbPb_276_PCE_mass_3sigma_f0_newparams_0" "PbPb_276_PCE_both_3sigma_f0_newparams_0"    
data_file="particles_pion.data"
fail_count=0

for dir_name in "${dirs[@]}"; do
    subdirname="$dirname/$dir_name"

    for dir in $subdirname/*; do
        # count regular files inside directory (not subdirectories)
        count=$(find "$dir/Kernels" -maxdepth 1 -type f | wc -l)

        if [ "$count" -ne 4 ]; then
            echo "$dir has $count files (NOT 4)"
            rsync -av --ignore-existing tweinrei@files:/lustre/alice/users/tweinrei/Master/FastReso/$dir/Kj/* "$dir/Kernels/"
            if [ $? -ne 0 ]; then
                ((fail_count++))
            fi
            echo "Copied kernels for list $i"
        else
            echo "$dir has $count files (OK)"
        fi
    done
    echo -e "Completed copying for dir $dir_name \n"
    echo "Number of failed copies for dir $dir_name: $fail_count"
done


