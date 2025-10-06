# ----------------------------------------------------------------------------------------------------------------------
# TBW
# ----------------------------------------------------------------------------------------------------------------------

# Note the space in front of the SSM parameter name.
# In Windows, namely when running the script with Git Bash, the messing with the path
# See:
# https://stackoverflow.com/questions/52921242/aws-ssm-put-parameter-validation-exception
# answer:
# https://stackoverflow.com/a/72833612/7145751
_run_pipeline _pipeline_name_prefix:
    #!{{bash_shebang}}
    echo "================================= Run pipeline ================================="
    echo "base_stack_name: {{base_stack_name}}"
    echo "pipeline_name_prefix: {{_pipeline_name_prefix}}"
    echo "pipeline: {{_pipeline_name_prefix}}-{{base_stack_name}}"
    echo "status check sleep time: {{status_check_sleep_time}}"
    echo "--------------------------------------------------------------------------------"

    IMAGE_VERSION_ARN=$(aws imagebuilder \
                        --no-cli-pager \
                        start-image-pipeline-execution \
                        --image-pipeline-arn \
                          $(\
                            aws imagebuilder \
                            --no-cli-pager \
                            list-image-pipelines \
                            --query "imagePipelineList[?starts_with(name,'{{_pipeline_name_prefix}}-{{base_stack_name}}')].arn | [0]" \
                            | sed -e 's/"//g'\
                          ) | \
                      jq -r ".imageBuildVersionArn")
    echo "ImageVersionArn: ${IMAGE_VERSION_ARN}"

    while : ; do
      status=$(aws imagebuilder \
             --no-cli-pager \
             get-image \
             --query "image.state.status" \
             --image-build-version-arn ${IMAGE_VERSION_ARN} |
             sed -e 's/"//g')
      echo "Waiting for ${IMAGE_VERSION_ARN} to be built - status: ${status}"
      sleep {{status_check_sleep_time}}

      if [[ -z "$status" ]]; then
        echo "Status is empty, error creating image?"
        exit 0
      fi

      if [[ "$status" == "FAILED" ]]; then
        echo "Image final status: ${status}, raise an error"
        exit 1
      fi

      if [[ "$status" == "AVAILABLE" ]]; then
        echo "Stack final status: ${status}, no error, continue"
        break
      fi
    done

    AMI_ID=$(aws imagebuilder \
             --no-cli-pager \
             get-image \
             --query "image.outputResources.amis[0].image" \
             --image-build-version-arn ${IMAGE_VERSION_ARN} |
             sed -e 's/"//g')
    echo "AmiId: ${AMI_ID}"

    aws ssm \
      --no-cli-pager \
      put-parameter \
      --name " /ami_id/{{stack_type}}/{{base_stack_name}}/{{_pipeline_name_prefix}}" \
      --value "${AMI_ID}" \
      --type String \
      --overwrite

_run_pipeline_nowait _pipeline_name_prefix:
    #!{{bash_shebang}}
    echo "================================= Run pipeline ================================="
    echo "base_stack_name: {{base_stack_name}}"
    echo "pipeline_name_prefix: {{_pipeline_name_prefix}}"
    echo "pipeline: {{_pipeline_name_prefix}}-{{base_stack_name}}"
    echo "--------------------------------------------------------------------------------"

    IMAGE_VERSION_ARN=$(aws imagebuilder \
    --no-cli-pager \
    start-image-pipeline-execution \
    --image-pipeline-arn \
        $(\
        aws imagebuilder \
        list-image-pipelines \
        --no-cli-pager \
        --query "imagePipelineList[?starts_with(name,'{{_pipeline_name_prefix}}-{{base_stack_name}}')].arn | [0]" \
        | sed -e 's/"//g'\
        ) |
      jq -r ".imageBuildVersionArn")
    echo "ImageVersionArn: ${IMAGE_VERSION_ARN}"

_delete_pipeline_image _image_name_prefix:
    #!{{bash_shebang}}
    echo "=============================== Delete pipeline -==============================="
    echo "base_stack_name: {{base_stack_name}}"
    echo "image_name_prefix: {{_image_name_prefix}}"
    echo "image: {{_image_name_prefix}}-{{base_stack_name}}"
    echo "--------------------------------------------------------------------------------"

    IMAGE_ARN=$(\
      aws imagebuilder \
      --no-cli-pager \
      list-images \
      --query "imageVersionList[?starts_with(name,'{{_image_name_prefix}}-{{base_stack_name}}')].arn | [0]" \
      | sed -e 's/"//g'\
    )
    echo "ImageArn: ${IMAGE_ARN}"

    IMAGE_VERSION_ARN_LIST=($(aws imagebuilder \
      --no-cli-pager \
      list-image-build-versions \
      --query "imageSummaryList[*].arn" \
      --image-version-arn ${IMAGE_ARN} |
      sed -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/,/ /g'))

    for IMAGE_VERSION_ARN in ${IMAGE_VERSION_ARN_LIST[@]}; do
      echo "Deleting image: ${IMAGE_VERSION_ARN}"
      aws imagebuilder \
        --no-cli-pager \
        delete-image \
        --image-build-version-arn ${IMAGE_VERSION_ARN}
    done

_delete_ami_and_snapshot _image_name_prefix:
    #!{{bash_shebang}}
    echo "============================ Delete AMI and snapshot ==========================="
    echo "base_stack_name: {{base_stack_name}}"
    echo "image_name_prefix: {{_image_name_prefix}}"
    echo "image: {{_image_name_prefix}}-{{base_stack_name}}"
    echo "--------------------------------------------------------------------------------"

    IMAGE_IDS=($(aws ec2 \
      --no-cli-pager \
      describe-images \
      --query "Images[?starts_with(Name,'{{_image_name_prefix}}-{{base_stack_name}}')].ImageId" \
      --owner self |
      sed -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/,/ /g'))

    SNAPSHOT_IDS=($(aws ec2 \
      --no-cli-pager \
      describe-images \
      --query "Images[?starts_with(Name,'{{_image_name_prefix}}-{{base_stack_name}}')].BlockDeviceMappings[*].Ebs.SnapshotId[]" \
      --owner self |
      sed -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/,/ /g'))

    for IMAGE_ID in ${IMAGE_IDS[@]}; do
        echo "Deregister ImageId: ${IMAGE_ID}"
        aws ec2 \
          --no-cli-pager \
          deregister-image \
          --image-id ${IMAGE_ID}
    done

    for SNAPSHOT_ID in ${SNAPSHOT_IDS[@]}; do
        echo "Delete SnapshotId: ${SNAPSHOT_ID}"
        aws ec2 \
          --no-cli-pager \
          delete-snapshot \
          --snapshot-id ${SNAPSHOT_ID}
    done

# TODO - add check for base and env stack names
_terminate_failed_build_images:
    #!{{bash_shebang}}
    echo "========================= Terminate failed build images ========================"
    echo "base_stack_name: {{base_stack_name}}"
    echo "--------------------------------------------------------------------------------"

    instance_list=($(aws ec2 \
      --no-cli-pager \
      describe-instances \
      --filter "Name=tag-key,Values=Ec2ImageBuilderArn" \
      --query "Reservations[*].Instances[].InstanceId[]" |
      sed -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/,/ /g'))

    for instance_id in ${instance_list[@]}; do
        echo "Terminating instance: ${instance_id}"
        aws ec2 \
          --no-cli-pager \
          terminate-instances \
          --instance-ids ${instance_id}
    done
