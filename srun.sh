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

BBOX=false
BASE=false

while [ "$1" != "" ]; do
    case $1 in
        --mode )
            shift
            MODE=$1
        ;;
        --ckpt )
            shift
            CKPT=$1
        ;;
        --seed )
	    shift
	    SEED=$1
	;;
        --bbox )
            BBOX=true
        ;;
        --base )
            BASE=true
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

ARGS="--cfg configs/config_default.yaml"

if [ $MODE == "train" ]; then
    if [ -z $SEED ]; then
        echo "--seed [0-9]+ is required for --mode train"
        exit
    else
	ARGS="${ARGS} --seed ${SEED}"
    fi
else
    if [ $MODE == "eval" ]; then
        if [ -z $CKPT ]; then
            echo "--ckpt is required for --mode eval" 
            exit
        fi
    else
        echo "--mode [train|eval] is required"
        exit
    fi
fi

if [ $BASE == true ]; then
    ARGS="${ARGS} --base"
fi

if [ $BBOX == true ]; then
    ARGS="${ARGS} --bbox"
fi

if [ -v CKPT ]; then
    ARGS="${ARGS} --ckpt ${CKPT}"
fi

MODE="${MODE}.py"

COMMAND="python ${MODE} ${ARGS}"

echo "Running with \"${COMMAND}\""

srun --nodes=${SLURM_NNODES} bash -c "source /cvgl2/u/jkamalu/miniconda3/bin/activate && conda activate vibe-env && cd /cvgl2/u/jkamalu/VIBE && ${COMMAND}"

# done
echo "Done"
