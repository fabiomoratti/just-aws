# ----------------------------------------------------------------------------------------------------------------------
# TBW
# ----------------------------------------------------------------------------------------------------------------------

_empty_base_bucket _component _bucket_name:
    #!{{bash_shebang}}
    echo "=============================== Empty base bucket =============================="
    echo "stack_name: {{base_stack_name}}"
    echo "component: {{_component}}"
    echo "bucket_name: {{_bucket_name}}"
    echo "--------------------------------------------------------------------------------"

    stack_instances=$(aws cloudformation \
        --no-cli-pager \
        list-stacks \
        --stack-status-filter CREATE_COMPLETE DELETE_FAILED \
        --query "length( StackSummaries[?starts_with(StackName,'{{base_stack_name}}-{{_component}}')].\
        {StackName:StackName, StackStatus:StackStatus} )" )

    if [[ "$stack_instances" == "0" ]]; then
        echo "Number of stack instances named {{base_stack_name}}-{{_component}}: ${stack_instances}, no stacks, nothing to do"
        exit 0
    fi
    echo "Number of stack instances named {{base_stack_name}}-{{_component}}: ${stack_instances}, delete the bucket"

    # TODO - extract the function to get a stack output
    bucket_name=$(aws cloudformation \
        --no-cli-pager \
        describe-stacks \
        --stack-name {{base_stack_name}}-{{_component}} \
        --query "Stacks[0].\
        Outputs[?OutputKey=='{{_bucket_name}}'].\
        OutputValue|[0]" | \
        sed -e 's/"//g')
    echo "Bucket to be deleted: ${bucket_name}"

    echo "Check if bucket ${bucket_name} exists"
    cmd_output=$(aws s3api head-bucket \
        --no-cli-pager \
        --bucket ${bucket_name} 2>&1 )
    cmd_exit_code=$?

    echo "head-bucket command returned: ${cmd_output}"
    echo "head-bucket return code is: $cmd_exit_code"

    if [[ "$cmd_exit_code" != "0" ]] then
      echo "bucket: ${bucket_name} does NOT exist, already deleted?"
      exit 0
    fi

    echo "bucket: ${bucket_name} does exist, deleting"

    aws s3 \
        --no-cli-pager \
        rm \
        --only-show-errors \
        s3://${bucket_name}/ \
        --recursive

    aws s3api \
    --no-cli-pager \
    delete-bucket \
    --bucket ${bucket_name}


_empty_bucket _component _bucket_name:
    #!{{bash_shebang}}
    echo "=============================== Empty base bucket =============================="
    echo "stack_name: {{main_stack_name}}"
    echo "component: {{_component}}"
    echo "bucket_name: {{_bucket_name}}"
    echo "--------------------------------------------------------------------------------"

    stack_instances=$(aws cloudformation \
        --no-cli-pager \
        list-stacks \
        --stack-status-filter CREATE_COMPLETE DELETE_FAILED \
        --query "length( StackSummaries[?starts_with(StackName,'{{main_stack_name}}-{{_component}}')].\
        {StackName:StackName, StackStatus:StackStatus} )" )

    if [[ "$stack_instances" == "0" ]]; then
        echo "Number of stack instances named {{main_stack_name}}-{{_component}}: ${stack_instances}, no stacks, nothing to do"
        exit 0
    fi
    echo "Number of stack instances named {{main_stack_name}}-{{_component}}: ${stack_instances}, delete the bucket"

    # TODO - extract the function to get a stack output
    bucket_name=$(aws cloudformation \
        --no-cli-pager \
        describe-stacks \
        --stack-name {{main_stack_name}}-{{_component}} \
        --query "Stacks[0].\
        Outputs[?OutputKey=='{{_bucket_name}}'].\
        OutputValue|[0]" | \
        sed -e 's/"//g')
    echo "Bucket to be deleted: ${bucket_name}"

    echo "Check if bucket ${bucket_name} exists"
    cmd_output=$(aws s3api head-bucket \
        --no-cli-pager \
        --bucket ${bucket_name} 2>&1 )
    cmd_exit_code=$?

    echo "head-bucket command returned: ${cmd_output}"
    echo "head-bucket return code is: $cmd_exit_code"

    if [[ "$cmd_exit_code" != "0" ]] then
      echo "bucket: ${bucket_name} does NOT exist, already deleted?"
      exit 0
    fi

    echo "bucket: ${bucket_name} does exist, deleting"

    aws s3 \
        --no-cli-pager \
        rm \
        --only-show-errors \
        s3://${bucket_name}/ \
        --recursive

    aws s3api \
    --no-cli-pager \
    delete-bucket \
    --bucket ${bucket_name}

