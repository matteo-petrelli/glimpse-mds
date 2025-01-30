#!/bin/bash
#SBATCH --partition=main                                 # Ask for unkillable job
#SBATCH --gres=gpu:1
#SBATCH --mem=10G                                        # Ask for 10 GB of RAM
#SBATCH --time=2:00:00                                   # The job will run for 3 hours
#SBATCH --output=./logs/abstractive_out.txt
#SBATCH --error=./logs/abstractive_error.txt
#SBATCH -c 2


# Load the required modules
module --quiet load miniconda/3
module --quiet load cuda/12.1.1
conda activate "glimpse"


# Check if input file path is provided and valid
if [ -z "$1" ] || [ ! -f "$1" ]; then
    # if no path is provided, or the path is invalid, use the default test dataset
    echo "Couldn't find a valid path. Using default path: data/processed/business_articles.csv"
    dataset_path="data/processed/business_articles.csv"
else
    dataset_path="$1"
fi

# Generate extractive summaries
candidates=$(python glimpse/data_loading/generate_extractive_candidates.py --dataset_path "$dataset_path" --scripted-run | tail -n 1)

# Compute the RSA scores based on the generated summaries
rsa_scores=$(python glimpse/src/compute_rsa.py --summaries $candidates | tail -n 1)

