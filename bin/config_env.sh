#!/bin/bash
./util/print_env.sh
mkdir -p /scratch/${CI_PROJECT_NAME}_${CI_PIPELINE_ID}
mkdir -p /scratch/${CI_PROJECT_NAME}_${CI_PIPELINE_ID}/sim_output
ls -lrth 

