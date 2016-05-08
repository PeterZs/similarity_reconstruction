#!/bin/bash
# the binary file of reconstruction program
set -e

. ./init.sh

merge_bin=$bin_dir/merge_tsdfs_obbs

#run_root=$result_root/seperate-seq-batch-seq-6050-6350-cropped-train-test2/
#run_root=$result_root/seperate-seq-batch-all-seq3-detector-building2-car-try3-cameraready-noscale-iccvres3-interleave-align-pca20-allsamples-rpcamjb/
run_root=$result_root/refactered-100reconweight-1470building3/
run_root=$result_root/refactered-compare_joint_recon/
#run_root=$result_root/seperate-seq-batch-all-detector-try3-cameraready-noscale-iccvres3-interleave-align-pca20-allsamples/
#run_root=$result_root/seperate-seq-batch-all-seq1-detector-building-car-try2/
#run_root=$result_root/seperate-seq-batch-all-seq0-detector-prevdetect/
if [ ! -d $run_root ]; then
    mkdir $run_root
fi

vx_arr=(9 9 6)
vy_arr=(9 9 6)
vz_arr=(6 6 5)

vx_arr=(9 9 9)
vy_arr=(9 9 9)
vz_arr=(6 6 6)

train_detect_delta_x_arr=(1 1 0.2)
train_detect_delta_y_arr=(1 1 0.2)
train_detect_delta_rot_arr=(2.5 2.5 2.5) # degree 

#detect_delta_x_arr=(0.5 0.4)
#detect_delta_y_arr=(0.5 0.4)
#detect_delta_rot_arr=(5 5)

detect_delta_x_arr=(1 1 0.4)
detect_delta_y_arr=(1 1 0.4)
detect_delta_rot_arr=(2 2 5)

#detect_delta_x_arr=(10 10)
#detect_delta_y_arr=(10 10)
#detect_delta_rot_arr=(30 30)

mesh_min_weight_arr=(0.0 0.0 0.0)
total_thread_arr=(10 10 10)
jitter_num_arr=(10 10 20)
sample_num_arr=(2000 2000 2000)
lowest_score_to_supress_arr=(-0.5 -0.5 -0.5)
noise_counter_thresh_arr=(2 2 3)
noise_comp_thresh_arr=(-1 -1 -1)

category_arr=(building building2 car)
startimg_arr=(1470 1890 3320 6050)
endimg_arr=(1790 2090 3530 6350)

merge_score_thresh_arr=(-0 -0 -0)
do_train_detector_arr=(0 0 0)
do_detection_arr=(1 1 1)
do_NMS_arr=(1 1 1)
do_pr_arr=(1 1 1)
do_adjust_obbs_arr=(1 1 1)
do_merge_tsdf_obb_arr=(1 1 1)

load_detection_from_folder=1
detection_root=/home/dell/results_5/detection_results/

do_init_consistent_check_arr=(1 1 1)
#do_init_skymap=(1 1 1)
#init_depth_check_arr=(1 1 1)
do_init_skymap=(1 1 1)
init_depth_check_arr=(1 1 1)

do_final_merge=1
do_final_joint_carbuildinglearn=1
do_joint_learn_arr=(1 1 1 $do_final_joint_carbuildinglearn)
do_consistency_check_arr=(1 1 1)

#final_do_consistency_check_arr=(0 0)
#final_do_skymap=(0 1)
#final_depth_check_arr=(0 0)

final_do_consistency_check_arr=1
final_do_skymap=1
final_depth_check_arr=1

#cur_param:
#lambda_obs_arr=(0.2 0.2 0.2)
#lambda_average_scale_arr=(1000 1000 1000)

#lambda_obs_arr=(0.2 0.3 0.2)
##lambda_obs_arr=(0.2 0.2 0.2)
#lambda_average_scale_arr=(50 1000 1000)
##lambda_average_scale_arr=(1000 1000 1000)
lambda_obs_arr=(0.0 0.0 0.0)
#car: 0.1, avg_scale 1000
lambda_average_scale_arr=(1000 100 1000)
lambda_average_scale_arr=(100 100 100)
lambda_reg_rot_arr=(50.0 50.0 50.0)
lambda_reg_scale_arr=(50.0 50.0 50.0)
lambda_reg_trans_arr=(50.0 50.0 50.0)
lambda_reg_zscale_arr=(0 0 0)
max_iter_arr=(3 3 3)
#max_iter_arr=(300 300 300)

## seq 1890
#lambda_obs_arr=(0.3 0.2 0.2)
#lambda_average_scale_arr=(50 1000 1000)
#lambda_reg_rot_arr=(50.0 50.0 50.0)
#lambda_reg_scale_arr=(50.0 50.0 50.0)
#lambda_reg_trans_arr=(50.0 50.0 50.0)
#lambda_reg_zscale_arr=(2000 0 0)
#
## seq 3320
#lambda_obs_arr=(0.2 0.2 0.2)
#lambda_average_scale_arr=(1000 1000 1000)
#lambda_reg_rot_arr=(50.0 50.0 50.0)
#lambda_reg_scale_arr=(50.0 50.0 50.0)
#lambda_reg_trans_arr=(50.0 50.0 50.0)
#lambda_reg_zscale_arr=(0 0 0)
#
## seq 6050
#lambda_obs_arr=(0.3 0.2 0.0)
#lambda_obs_arr=(0.0 0.2 0.0)
#lambda_average_scale_arr=(500.0 1000 1000)
#lambda_average_scale_arr=(100.0 1000 1000)
#lambda_reg_rot_arr=(50.0 50.0 50.0)
#lambda_reg_scale_arr=(50.0 50.0 50.0)
#lambda_reg_trans_arr=(50.0 50.0 50.0)
#lambda_reg_zscale_arr=(0 0 0)
final_consistency_check=1

svm_w1_arr=(10 10 10)
svm_cs_arr=(100 100 100)


declare -A detected_obb_file_arr
declare -A train_detected_obb_file_arr
declare -A train_input_tsdf_arr

declare -A merged_model_arr
declare -A merged_detect_box_txt_arr

for seq_i in 0 1 2 3
do
    startimg=${startimg_arr[$seq_i]}
    endimg=${endimg_arr[$seq_i]}
    input_tsdf_arr[$seq_i]=$result_root/reconstruction_closest_3/vri-fusing-result5_cam_3_with_2-st-$startimg-ed-$endimg-vlen-0.2-rampsz-6-try1/recon-$startimg-$endimg-vlen-0.2-rampsz-6_tsdf.bin

    for ci in 0 1 2
    do
        category=${category_arr[$ci]}
        detected_obb_file_arr[$seq_i $ci]=/home/dell/Data/download_labels/label_4_12/gt_4_12_$startimg-$endimg-$category/gt_$startimg-$endimg-$category".txt"
        train_input_tsdf_arr[$seq_i $ci]=$result_root/cropped_tsdf_for_training/gt_cropped_$startimg-$endimg-$category/gt_cropped_$startimg-$endimg-$category".cropped_tsdf_tsdf.bin"
        train_detected_obb_file_arr[$seq_i $ci]=$result_root/cropped_tsdf_for_training/gt_cropped_$startimg-$endimg-$category/gt_cropped_$startimg-$endimg-$category".obb_info.txt"
        #echo ${detected_obb_file_arr[$seq_i $ci]}
    done
done

test_seq_idx[0]="0 1 2 3"
test_seq_idx[1]="1 0 2 3"
test_seq_idx[2]="2 0 1 3"
test_seq_idx[3]="3 0 1 2"

#svm_w1s=(1)
#svm_cs=(10)

#for svm_w1 in ${svm_w1s[@]}; do
#    for svm_c in ${svm_cs[@]}; do

for test_pcanum in 0
do
pca_num_arr=(0 0 0)
pca_num_arr=($test_pcanum $test_pcanum $test_pcanum)

for ci in 0 #0 1  #2 #0 1 2 #1
do
   ## if [ $svm_w1 -eq 1 && $svm_c -eq 0.1 ]; then continue; fi
   ## if [ $svm_w1 -eq 1 && $svm_c -eq 1 ]; then continue; fi

for seq_i in 1 #1 2 3 #2 3 #1 2 3
do
#    if [ $ci -eq 0 ]; then
#        continue;
#    fi
#    if [ $ci -eq  1 ] && [ $seq_i -eq 0 ]; then
#        continue;
#    fi
    do_train_detector=${do_train_detector_arr[$ci]}
    do_detection=${do_detection_arr[$ci]}
    do_NMS=${do_NMS_arr[$ci]}
    do_pr=${do_pr_arr[$ci]}
    do_merge_tsdf_obb=${do_merge_tsdf_obb_arr[$ci]}
    do_joint_learn=${do_joint_learn_arr[$ci]}

    svm_w1=${svm_w1_arr[$ci]}
    svm_c=${svm_cs_arr[$ci]}

    vx=${vx_arr[$ci]}
    vy=${vy_arr[$ci]}
    vz=${vz_arr[$ci]}

    train_detect_delta_x=${train_detect_delta_x_arr[$ci]}
    train_detect_delta_y=${train_detect_delta_y_arr[$ci]}
    train_detect_delta_rot=${train_detect_delta_rot_arr[$ci]} # degree

    detect_delta_x=${detect_delta_x_arr[$ci]}
    detect_delta_y=${detect_delta_y_arr[$ci]}
    detect_delta_rot=${detect_delta_rot_arr[$ci]}

    mesh_min_weight=${mesh_min_weight_arr[$ci]}
    total_thread=${total_thread_arr[$ci]}
    jitter_num=${jitter_num_arr[$ci]}
    sample_num=${sample_num_arr[$ci]}
    lowest_score_to_supress=${lowest_score_to_supress_arr[$ci]}
    noise_counter_thresh=${noise_counter_thresh_arr[$ci]}
    noise_comp_thresh=${noise_comp_thresh_arr[$ci]}
    merge_score_thresh=${merge_score_thresh_arr[$ci]}

    detect_output_suffix="detect-try1-voxelsides-$vx-$vy-$vz-dx-$detect_delta_x-dy-$detect_delta_y-dr-$detect_delta_rot-jitter-$jitter_num"
    output_suffix="try1-voxelsides-$vx-$vy-$vz-dx-$train_delta_x-dy-$train_delta_y-dr-$train_delta_rot-jitter-$jitter_num"
    echo detect_output_suffix $detect_output_suffix
    echo output_suffix $output_suffix
    startimg=${startimg_arr[$seq_i]}
    endimg=${endimg_arr[$seq_i]}
    category=${category_arr[$ci]}
    input_tsdf=${input_tsdf_arr[$seq_i]}
    detected_obb_file=${detected_obb_file_arr[$seq_i $ci]}
    train_input_tsdf=${train_input_tsdf_arr[$seq_i $ci]}
    train_detected_obb_file=${train_detected_obb_file_arr[$seq_i $ci]}
    batch_output_root=$run_root/batch-res2-$startimg-$endimg-$category-svmw1-$svm_w1-svmc-$svm_c
    if [ ! -d $batch_output_root ]; then
        mkdir $batch_output_root
    fi

    echo startimg $startimg
    echo endimg $endimg
    echo category $category
    echo input_tsdf: $input_tsdf
    echo detected_obb_file: $detected_obb_file
    echo train_input_tsdf: $train_input_tsdf
    echo train_detected_obb_file: $train_detected_obb_file
    echo batch_output_root $batch_output_root
    echo svm_c $svm_c
    echo svm_w1 $svm_w1
    sleep 1

    if [ $load_detection_from_folder -le 0 ]; then
        echo "init consistency check for object detection training and testing"
        echo "################## run training ###################"
        # in: input_tsdf, detected_obb_file
        tmp_detected_obb_file=$detected_obb_file
        tmp_input_tsdf=$input_tsdf
        input_tsdf=$train_input_tsdf
        detected_obb_file=$train_detected_obb_file
        . ./run-train-detector.sh 
        detected_obb_file=$tmp_detected_obb_file
        input_tsdf=$tmp_input_tsdf
        # trained_svm_path=$trained_svm_path".trained_svm_model.svm"

        echo "################## run detection ###################"
        test_seq_i=$seq_i
        test_startimg=${startimg_arr[$test_seq_i]}
        test_endimg=${endimg_arr[$test_seq_i]}
        test_input_tsdf=${input_tsdf_arr[$test_seq_i]}
        test_detected_obb_file=${detected_obb_file_arr[$test_seq_i $ci]}
        detect_output_root=$batch_output_root/detect-test-res-fullseq-$test_startimg-$test_endimg/
        if [ ! -d $detect_output_root ]; then
            mkdir $detect_output_root
        fi
        echo test_startimg $test_startimg
        echo test_endimg $test_endimg
        echo category $category
        echo test_input_tsdf $test_input_tsdf
        echo test_detected_obb_file $test_detected_obb_file
        echo detect_output_root $detect_output_root
        sleep 1
        echo "run detection"
        . ./run-sliding-window-detect.sh 
        # detect_res_path=$detect_output_prefix"_SlidingBoxDetectionResults_Parallel_Final.txt"
        echo detect_res_path $detect_res_path
        echo template_obb_path $template_obb_path

        echo "compute pr curve"
        sleep 1
        pr_output_root=$detect_output_root
        . ./compute_pr_curve.sh
        # nms_res=$pr_curve_output_prefix"NMS_res.txt"
        # detect_obb_infos=$pr_curve_output_dir"_obb_infos.txt"
        cur_detect_obb_infos[$test_seq_i]=$detect_obb_infos
        cur_detect_obb_scores[$test_seq_i]=$detect_obb_scores
        #done

        echo "######################## adjust detected bbs ################"
        do_adjust_obbs=${do_adjust_obbs_arr[$ci]}
        adjust_output_root=$detect_output_root
        . ./run-adjust-obbs.sh
        echo adjusted_obb_txt $adjusted_obb_txt
        echo adjusted_score_txt $adjusted_score_txt
        detect_obb_infos=$adjusted_obb_txt
        detected_obb_scores=$adjusted_score_txt

        echo "######################## adjust bbs 2 ########################"
        . ./run-adjust-obbs2-1.sh
        echo adjusted_obb_txt $adjusted_obb_txt
        echo adjusted_score_txt $adjusted_score_txt
        detect_obb_infos=$adjusted_obb_txt
        detected_obb_scores=$adjusted_score_txt

        ##############################################
        echo "################## merge tsdf/obbs for one category ###################"
        merge_output_dir=$batch_output_root/merge_tsdf_obb_output-trainingseq-$seq_i-merge_score_thresh-$merge_score_thresh
        if [ ! -d $merge_output_dir ]; then
            mkdir $merge_output_dir
        fi
        merge_output_prefix=$merge_output_dir/merged_model
        #model_fileoption="--in-models "$(IFS=$' '; echo "${input_tsdf_arr[*]}")
        model_fileoption=""
        if [ $do_merge_tsdf_obb -gt 0 ]; then
            echo $merge_bin --in-models $test_input_tsdf --in-obbs $detect_obb_infos --out $merge_output_prefix --obb-min-score $merge_score_thresh
            $merge_bin --in-models $test_input_tsdf --in-obbs $detect_obb_infos --out $merge_output_prefix --obb-min-score $merge_score_thresh
        fi
        merged_model=$merge_output_prefix"_tsdf.bin"
        merged_detect_box_txt=$merge_output_prefix".obb_infos.txt"

        merged_model_arr[$test_seq_i $ci]=$merged_model
        merged_detect_box_txt_arr[$test_seq_i $ci]=$merged_detect_box_txt
    else
        echo "################ loading detections from folders####################"
        merged_model=$detection_root/seq-$startimg-$endimg/$category/"merged_model_tsdf.bin"
        merged_detect_box_txt=$detection_root/seq-$startimg-$endimg/$category/"merged_model.obb_infos.txt"

#         merged_model=$input_tsdf
       #  merged_detect_box_txt=$result_root/detection_test_$startimg-3/detect_res_all.txt
       #  merged_detect_box_txt=$result_root/detection_test2_1470-delta-0.5-0.5-2/detect_res_all_obb_nmsed.txt
    fi
    echo merged_model $merged_model
    echo merged_dtect_box_txrt $merged_detect_box_txt

    echo "#################  prepare joint learn dirs for one category #############"
    pca_num=${pca_num_arr[$ci]}
    joint_learn_suffix=$seq_i-mergescore_thresh-$merge_score_thresh-noisecounter-$noise_counter_thresh-noisecompo-$noise_comp_thresh-iter-${max_iter_arr[$ci]}-pcanum-$pca_num
    joint_learn_output_root=$batch_output_root/joint_learn-rebut-$joint_learn_suffix
    if [ ! -d $joint_learn_output_root ]; then
        mkdir $joint_learn_output_root
    fi

    echo "################## initial consistency check for one category ###########"
    do_consistency_check=${do_init_consistent_check_arr[$ci]}
    echo $do_consistency_check
    joint_output_tsdf=$input_tsdf
    st_neighbor=-1
    ed_neighbor=2
    #depthmap_check=${init_depth_check_arr[$ci]}
    #skymap_check=${do_init_skymap[$ci]}
    depthmap_check=1
    skymap_check=1
    filter_noise=60
    consistency_check_root=$joint_learn_output_root/init_consistency_check-$joint_learn_suffix-$st_neighbor-$ed_neighbor
    echo consistency_check_root $consistency_check_root
    if [ ! -d $consistency_check_root ]; then
        mkdir $consistency_check_root
    fi
    consistency_tsdf=1
    . ./run-sky-consistency-checking.sh
    #. ./consistency_check.sh
    #consistent_tsdf_output=$out".tsdf_consistency_cleaned_tsdf.bin"

    echo "################## joint learn for one category ###################"
    merged_model=$consistent_tsdf_output
    lambda_obs=${lambda_obs_arr[$ci]}
    lambda_average_scale=${lambda_average_scale_arr[$ci]}
    lambda_reg_rot=${lambda_reg_rot_arr[$ci]}
    lambda_reg_scale=${lambda_reg_scale_arr[$ci]}
    lambda_reg_trans=${lambda_reg_trans_arr[$ci]}
    lambda_reg_zscale=${lambda_reg_zscale_arr[$ci]}
    lambda_avg_scale=$lambda_reg_rot
    max_iter=${max_iter_arr[$ci]}
    echo lambda_obs $lambda_obs
    #. ./joint_cluster_model.sh
    #. ./run-optimization2.sh
    . ./joint_cluster_model.sh
    #joint_learn_outdir=$output_dir

    echo "############### 2nd consistency for one category #########################"
    do_consistency_check=${do_consistency_check_arr[$ci]}
    #joint_output_tsdf=$joint_learn_outdir/"joint-opt._merged_tsdf_tsdf.bin"
    st_neighbor=0
    ed_neighbor=1
    depthmap_check=0 #${depth_check_arr[$ci]}
    skymap_check=1
    filter_noise=120
    consistency_check_root=$joint_learn_outdir/consistency_check-aftjointlearn-$joint_learn_suffix-$st_neighbor-$ed_neighbor-pcanum-$pca_num
    echo consistency_check_root $consistency_check_root
    if [ ! -d $consistency_check_root ]; then
        mkdir $consistency_check_root
    fi
    consistency_tsdf=0
    #. ./run-sky-consistency-checking.sh
    . ./consistency_check.sh
    consistent_tsdf_output_category_arr[$ci]=$consistent_tsdf_output
done
done

echo "##################### merging multiple categories tsdfs ###################"
IFS=' '
in_models_merge=${consistent_tsdf_output_category_arr[@]}
out_dir=$run_root/batch-res3-$startimg-$endimg-multi_cate_merged-pcanum-$pca_num
if [ ! -d $out_dir ]; then
    mkdir $out_dir
fi
out_prefix=$out_dir/out_sample
merge_multicate_bin=$bin_dir/test_merge_tsdf_multi_category
echo $merge_multicate_bin --in-models $in_models_merge --out $out_prefix
$merge_multicate_bin --in-models $in_models_merge --out $out_prefix

do_consistency_check=$final_do_consistency_check_arr
#the output of the merged model
joint_output_tsdf=$out_dir/out_samplemulti_cate_merged_tsdf.bin
merged_detect_box_txt=$out_dir/out_samplemulti_cate_merged_obb.txt
consistency_check_root=$out_dir/final_consistency_check-$joint_learn_suffix
if [ ! -d $consistency_check_root ] ; then
    mkdir $consistency_check_root
fi
echo consistency_check_root $consistency_check_root
st_neighbor=0
ed_neighbor=1
depthmap_check=0
skymap_check=0
if [ ! -d $consistency_check_root ]; then
    mkdir $consistency_check_root
fi
consistency_tsdf=0
. ./run-sky-consistency-checking.sh

# original model cleaned
do_consistency_check=$final_do_consistency_check_arr
test_input_tsdf=${input_tsdf_arr[$seq_i]}
joint_output_tsdf=$test_input_tsdf
merged_detect_box_txt=$out_dir/out_samplemulti_cate_merged_obb.txt
consistency_check_root=$out_dir/final_originrecon_consistency_check-$joint_learn_suffix
if [ ! -d $consistency_check_root ] ; then
    mkdir $consistency_check_root
fi
echo consistency_check_root $consistency_check_root
st_neighbor=0
ed_neighbor=1
depthmap_check=$final_depth_check_arr
skymap_check=$final_do_skymap
if [ ! -d $consistency_check_root ]; then
    mkdir $consistency_check_root
fi
consistency_tsdf=0
. ./run-sky-consistency-checking.sh
#consistent_tsdf_output_category_arr[$ci]=$consistent_tsdf_output
done
return

