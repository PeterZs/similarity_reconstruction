#!/bin/bash

run_reconstruction=0
run_crop_tsdf=0
run_train=0
run_detect=0
run_joint_opt=1
. ./init_paths.sh
. ./run_reconstruction_both_sides.sh
. ./run_crop_tsdf_as_gt_in_refactorcode.sh
detector_train_data_dir=$train_data_dir_computed
. ./run_detection_hdin.sh
. ./run_joint_reconstruction-hdin.sh
