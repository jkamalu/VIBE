#!/bin/bash
#SBATCH --partition=napoli-gpu
#SBATCH --nodes=1
#SBATCH --mem=64G
#SBATCH -c 8
#SBATCH --time 720

# only use the following on partition with GPUs
#SBATCH --gres=gpu:4

#SBATCH --job-name="vibe-repro"

OPTIND=1

while [ "$1" != "" ]; do
    case $1 in
        --mode )
            shift
            MODE=$1
        ;;
        --ckp )
            shift
            CKPT=$1
        ;;
        * )
            exit
    esac
    shift
done

if [ -z $MODE ]; then
    echo "--mode [train|eval] is required"
    exit
fi
MODE="${MODE}.py"

if [ -z $CKPT ]; then
    echo "--ckpt is required (currently unused)"
    exit
fi

# sample process (list hostnames of the nodes you've requested)
srun --nodes=${SLURM_NNODES} bash -c "source /cvgl/u/jkamalu/miniconda3/bin/activate && conda activate vibe-env && cd /cvgl/u/jkamalu/VIBE && python ${MODE} --cfg configs/config.yaml"

# done
echo "Done"
