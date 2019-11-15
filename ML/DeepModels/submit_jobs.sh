#!/bin/bash

spack load opencv ^python@3
spack load /ou2ujbv # Load pytorch by hash
spack load /5gjrsa2 # Load torchvision by hash
spack load /b4lfddj # Load scipy
spack load /5kmm4sh # Load matplotlib
spack load py-scikit-image ^python@3 # Load image manipulation library
spack load py-scikit-learn@0.21 # Load sklearn for metrics
spack load py-tensorboardx

model_num="1"
baseJobName="GIW_${model_num}"

echo "Submitting jobs ..."
declare -a PrTest=("1" "2" "3" "8" "9" "12" "16" "17" "22")

for PrIdx in "${PrTest[@]}"
do
    echo "Submitting $PrIdx"
    echo -e "#!/bin/bash \n python3 main.py --PrTest=${PrIdx} --lr=1e-5 --modeltype=${model_num} --batchsize=32 --epochs=1000" > command.lock
    sbatch -J ${baseJobName} --output="rc_log/${PrIdx}.o" --error="rc_log/${PrIdx}.e" --mem=16G -n 1 -t 2-8:0:0 -p tier3 -A riteyes --gres=gpu:1 --mail-user=rsk3900@rit.edu --mail-type=ALL command.lock
done