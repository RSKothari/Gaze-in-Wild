#!/bin/bash

# Author: Rakshit Kothari
# Credit: Sanketh Moudgalya for sharing bash script

spack load opencv ^python@3
spack load /jthz32l # Load pytorch by hash
spack load /5gjrsa2 # Load torchvision by hash
spack load /b4lfddj # Load scipy
spack load /5kmm4sh # Load matplotlib
spack load py-scikit-image ^python@3 # Load image manipulation library
spack load py-scikit-learn@0.21 # Load sklearn for metrics
spack load py-tensorboardx

declare -a model_list=("1" "2" "3" "4" "5" "8" "9")

for model_num in "${model_list[@]}"
do
    echo "Submitting jobs ..."
    declare -a PrTest=("1" "2" "3" "6" "8" "9" "12" "16" "17" "22")

    for PrIdx in "${PrTest[@]}"
    do
        baseJobName="nt_${PrIdx}_${model_num}"
        echo "Submitting $PrIdx"
        echo -e "#!/bin/bash \n python3 main_notest.py --PrTest=${PrIdx} --lr=1e-4 --modeltype=${model_num} --batchsize=64 --epochs=250" > command.lock
        sbatch -J ${baseJobName} --output="rc_log_notest/${PrIdx}_${model_num}.o" --error="rc_log_notest/${PrIdx}_${model_num}.e" --mem=16G -n 1 -t 0-8:0:0 -p tier3 -A riteyes --gres=gpu:1 --mail-user=rsk3900@rit.edu --mail-type=ALL command.lock
    done
done
