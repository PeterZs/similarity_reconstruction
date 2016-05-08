#!/bin/bash
# the binary file of reconstruction program
test_bin=/home/dell/codebase/mpi_project/urban_reconstruction/code/build/hashmap/bin/test_tsdf_feature_generate

# input_model
input_model=/home/dell/codebase/mpi_project/urban_reconstruction/code/build/hashmap/results/output-3d-model-semantic/ply-0-600-0.5-newtest-conf-flatten-1-noclean_bin_tsdf_file.bin

# input_sample
input_samples=/home/dell/Data/results/house-sliced-res-1/h-joint-align_tsdf_sliced_0.bin" "/home/dell/Data/results/house-sliced-res-1/h-joint-align_tsdf_sliced_1.bin" "/home/dell/Data/results/house-sliced-res-1/h-joint-align_tsdf_sliced_2.bin

# output_prefix
output_prefix=/home/dell/codebase/mpi_project/urban_reconstruction/code/build/hashmap/results/tsdf_feature_test_600frame_11_onesample_jittering
if [ ! -d "$output_prefix" ]; then
mkdir $output_prefix
fi
output_prefix=$output_prefix"/house_1"

set -e

echo "$test_bin $input_samples --in-model $input_model --out-dir-prefix $output_prefix --save_tsdf_bin --sample_num 3 --mesh-min-weight 0.5"

$test_bin $input_samples --in-model $input_model --out-dir-prefix $output_prefix --save_tsdf_bin --sample_num 2000 --mesh-min-weight 0.2
