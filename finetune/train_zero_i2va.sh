#!/usr/bin/env bash

# Prevent tokenizer parallelism issues
export TOKENIZERS_PARALLELISM=false

# Model Configuration
MODEL_ARGS=(
    --model_path "/disk0/home/kuowei/my_solution/CogVideoX1.5-5B-I2V"
    --model_name "cogvideox1.5-i2va"  # ["cogvideox-i2v"]
    --model_type "i2va"
    --training_type "sft"
)

# Output Configuration
OUTPUT_ARGS=(
    --output_dir "/disk0/home/kuowei/cogvideo_fineturn_debug_model"
    --report_to "tensorboard"
)

# Data Configuration
DATA_ARGS=(
    --data_root "/disk0/home/kuowei/bridge_finetune_gt_1000_action"
    --caption_column "prompts.txt"
    --video_column "videos.txt"
    --action_column "actions.txt"
    --image_column "images.txt"  # comment this line will use first frame of video as image conditioning
    --train_resolution "41x480x640"  # (frames x height x width), frames should be 8N+1 and height, width should be multiples of 16
)

# Training Configuration
TRAIN_ARGS=(
    --train_epochs 10 # number of training epochs ？是不是有点太大了
    --seed 42 # random seed

    #########   Please keep consistent with deepspeed config file ##########
    --batch_size 2 # 16
    --gradient_accumulation_steps 1
    --mixed_precision "bf16"  # ["no", "fp16"] Only CogVideoX-2B supports fp16 training
    ########################################################################
)

# System Configuration
SYSTEM_ARGS=(
    --num_workers 6
    --pin_memory True
    --nccl_timeout 1800
)

# Checkpointing Configuration
CHECKPOINT_ARGS=(
    --checkpointing_steps 10 # save checkpoint every x steps
    --checkpointing_limit 2 # maximum number of checkpoints to keep, after which the oldest one is deleted
    # --resume_from_checkpoint "/absolute/path/to/checkpoint_dir"  # if you want to resume from a checkpoint, otherwise, comment this line
)

# Validation Configuration
VALIDATION_ARGS=(
    --do_validation false  # ["true", "false"]
    --validation_dir "/absolute/path/to/validation_set"
    --validation_steps 20  # should be multiple of checkpointing_steps
    --validation_prompts "prompts.txt"
    --validation_images "images.txt"
    --gen_fps 16
)

# Combine all arguments and launch training
accelerate launch --config_file accelerate_config.yaml train.py \
    "${MODEL_ARGS[@]}" \
    "${OUTPUT_ARGS[@]}" \
    "${DATA_ARGS[@]}" \
    "${TRAIN_ARGS[@]}" \
    "${SYSTEM_ARGS[@]}" \
    "${CHECKPOINT_ARGS[@]}" \
    "${VALIDATION_ARGS[@]}"
