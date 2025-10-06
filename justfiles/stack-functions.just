# ----------------------------------------------------------------------------------------------------------------------
# TBW
# ----------------------------------------------------------------------------------------------------------------------

_copy_base_template _component:
    #!{{bash_shebang}}
    set -euxo pipefail
    echo "============================== Copy base template =============================="
    echo "component: {{_component}}"
    echo "local_stack_file: {{_component}}.yaml"
    echo "s3_path: s3://{{stack_bucket}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.yaml"
    echo "--------------------------------------------------"

    aws s3 cp {{_component}}.yaml s3://{{stack_bucket}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.yaml
    echo "--------------------------------------------------"

_copy_template _component:
    #!{{bash_shebang}}
    set -euxo pipefail
    echo "================================= Copy template ================================"
    echo "component: {{_component}}"
    echo "local_stack_file: {{_component}}.yaml"
    echo "s3_path: s3://{{stack_bucket}}/{{main_stack_name}}/{{main_stack_name}}-{{_component}}.yaml"
    echo "--------------------------------------------------------------------------------"

    aws s3 cp {{_component}}.yaml s3://{{stack_bucket}}/{{main_stack_name}}/{{main_stack_name}}-{{_component}}.yaml
    echo "--------------------------------------------------------------------------------"

_validate_base_template _component:
    #!{{bash_shebang}}
    set -euxo pipefail
    echo "============================ Validate base template ============================"
    echo "component: {{_component}}"
    echo "template_url: {{stack_bucket_endpoint}}/{{stack_bucket}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.yaml"
    echo "--------------------------------------------------------------------------------"

    aws cloudformation \
      --no-cli-pager \
      validate-template \
      --template-url \
      {{stack_bucket_endpoint}}/{{stack_bucket}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.yaml
    echo "--------------------------------------------------------------------------------"

_validate_template _component:
    #!{{bash_shebang}}
    set -euxo pipefail
    echo "=============================== Validate template =============================="
    echo "component: {{_component}}"
    echo "template_url: {{stack_bucket_endpoint}}/{{stack_bucket}}/{{main_stack_name}}/{{main_stack_name}}-{{_component}}.yaml"
    echo "--------------------------------------------------------------------------------"

    aws cloudformation \
      --no-cli-pager \
      validate-template \
      --template-url \
      {{stack_bucket_endpoint}}/{{stack_bucket}}/{{main_stack_name}}/{{main_stack_name}}-{{_component}}.yaml
    echo "--------------------------------------------------------------------------------"

_create_base_stack _component: \
    (_create_base_stack_with_region _component default_region)

_create_stack _component: \
    (_create_stack_with_region _component default_region)

_create_base_stack_no_param _component: \
    (_create_base_stack_no_param_with_region _component default_region)

_create_stack_no_param _component: \
    (_create_stack_no_param_with_region _component default_region)

_create_base_stack_with_region _component _region:
    #!{{bash_shebang}}
    echo "=============================== Create base stack =============================="
    echo "component: {{_component}}"
    echo "region: {{_region}}"
    echo "stack_name: {{base_stack_name}}-{{_component}}"
    echo "client_request_token: {{base_stack_name}}-{{_component}}-{{stack_token_post_fix}}"
    echo "template_url: {{stack_bucket_endpoint}}/{{stack_bucket}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.yaml"
    echo "parameters_file: {{parameters_dir}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.json"
    echo "--------------------------------------------------------------------------------"

    aws cloudformation \
      --no-cli-pager \
      create-stack \
      --disable-rollback \
      --region {{_region}} \
      --capabilities CAPABILITY_NAMED_IAM \
      --stack-name {{base_stack_name}}-{{_component}} \
      --client-request-token {{base_stack_name}}-{{_component}}-{{stack_token_post_fix}} \
      --template-url {{stack_bucket_endpoint}}/{{stack_bucket}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.yaml \
      --parameters file://{{parameters_dir}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.json
    echo "--------------------------------------------------------------------------------"

_create_stack_with_region _component _region:
    #!{{bash_shebang}}
    set -euxo pipefail
    echo "================================= Create stack ================================="
    echo "component: {{_component}}"
    echo "region: {{_region}}"
    echo "stack_name: {{main_stack_name}}-{{_component}}"
    echo "client_request_token: {{main_stack_name}}-{{_component}}-{{stack_token_post_fix}}"
    echo "template_url: {{stack_bucket_endpoint}}/{{stack_bucket}}/{{main_stack_name}}/{{main_stack_name}}-{{_component}}.yaml"
    echo "parameters_file: {{parameters_dir}}/{{base_stack_name}}/{{env_stack_name}}/{{main_stack_name}}-{{_component}}.json"
    echo "--------------------------------------------------------------------------------"

    aws cloudformation \
      --no-cli-pager \
      create-stack --disable-rollback \
      --region {{_region}} \
      --capabilities CAPABILITY_NAMED_IAM \
      --stack-name {{main_stack_name}}-{{_component}} \
      --client-request-token {{main_stack_name}}-{{_component}}-{{stack_token_post_fix}} \
      --template-url {{stack_bucket_endpoint}}/{{stack_bucket}}/{{main_stack_name}}/{{main_stack_name}}-{{_component}}.yaml \
      --parameters file://{{parameters_dir}}/{{base_stack_name}}/{{env_stack_name}}/{{main_stack_name}}-{{_component}}.json
    echo "--------------------------------------------------------------------------------"

_create_base_stack_no_param_with_region _component _region:
    #!{{bash_shebang}}
    echo "======================= Create base stack (no parameters) ======================"
    echo "component: {{_component}}"
    echo "region: {{_region}}"
    echo "stack_name: {{base_stack_name}}-{{_component}}"
    echo "client_request_token: {{base_stack_name}}-{{_component}}-{{stack_token_post_fix}}"
    echo "template_url: {{stack_bucket_endpoint}}/{{stack_bucket}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.yaml"
    echo "--------------------------------------------------------------------------------"

    aws cloudformation \
      --no-cli-pager \
      create-stack \
      --disable-rollback \
      --region {{_region}} \
      --capabilities CAPABILITY_NAMED_IAM \
      --stack-name {{base_stack_name}}-{{_component}} \
      --client-request-token {{base_stack_name}}-{{_component}}-{{stack_token_post_fix}} \
      --template-url {{stack_bucket_endpoint}}/{{stack_bucket}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.yaml
    echo "--------------------------------------------------------------------------------"

_create_stack_no_param_with_region _component _region:
    #!{{bash_shebang}}
    echo "=============== Create stack (no parameters) ==============="
    echo "component: {{_component}}"
    echo "region: {{_region}}"
    echo "stack_name: {{main_stack_name}}-{{_component}}"
    echo "client_request_token: {{main_stack_name}}-{{_component}}-{{stack_token_post_fix}}"
    echo "template_url: {{stack_bucket_endpoint}}/{{stack_bucket}}/{{main_stack_name}}/{{main_stack_name}}-{{_component}}.yaml"
    echo "--------------------------------------------------------------------------------"

    aws cloudformation \
        --no-cli-pager \
        create-stack \
        --disable-rollback \
        --region {{_region}} \
        --capabilities CAPABILITY_NAMED_IAM \
        --stack-name {{main_stack_name}}-{{_component}} \
        --client-request-token {{main_stack_name}}-{{_component}}-{{stack_token_post_fix}} \
        --template-url {{stack_bucket_endpoint}}/{{stack_bucket}}/{{main_stack_name}}/{{main_stack_name}}-{{_component}}.yaml
    echo "--------------------------------------------------------------------------------"

_create_base_stack_wait _component: \
    (_create_base_stack_wait_with_region _component default_region)

_create_stack_wait _component: \
    (_create_stack_wait_with_region _component default_region)

_create_base_stack_wait_with_region _component _region:
    #!{{bash_shebang}}
    echo "============================ Check base stack status ==========================="
    echo "component: {{_component}}"
    echo "region: {{_region}}"
    echo "status check sleep time: {{status_check_sleep_time}}"
    echo "stack_name: {{base_stack_name}}-{{_component}}"
    echo "--------------------------------------------------------------------------------"

    echo "Waiting for status..."
    sleep {{status_check_sleep_time}}

    echo "Waiting for status..."
    sleep {{status_check_sleep_time}}

    while : ; do
      status=$(aws cloudformation \
              --no-cli-pager \
              list-stacks \
              --region {{_region}} \
              --output text \
              --query "StackSummaries[?StackName=='{{base_stack_name}}-{{_component}}'][CreationTime,StackStatus]" | \
              sort -r | \
              head -1 | \
              awk '{print $2}')
      echo "Waiting for {{base_stack_name}}-{{_component}} creation, status: $status"

      sleep {{status_check_sleep_time}}

      if [[ "$status" == "CREATE_FAILED" ]]; then
        echo "Stack final status: ${status}, raise an error"
        exit 1
      fi

      if [[ "$status" == "CREATE_COMPLETE" ]]; then
        echo "Stack final status: ${status}, no error, continue"
        exit 0
      fi
    done

_create_stack_wait_with_region _component _region:
    #!{{bash_shebang}}
    echo "============================ Check base stack status ==========================="
    echo "component: {{_component}}"
    echo "region: {{_region}}"
    echo "status check sleep time: {{status_check_sleep_time}}"
    echo "stack_name: {{main_stack_name}}-{{_component}}"
    echo "--------------------------------------------------------------------------------"

    echo "Waiting for status..."
    sleep {{status_check_sleep_time}}

    echo "Waiting for status..."
    sleep {{status_check_sleep_time}}

    while : ; do \
      status=$(aws cloudformation \
              --no-cli-pager \
              list-stacks \
              --region {{_region}} \
              --output text \
              --query "StackSummaries[?StackName=='{{main_stack_name}}-{{_component}}'][CreationTime,StackStatus]" | \
              sort -r | \
              head -1 | \
              awk '{print $2}')
      echo "Waiting for {{main_stack_name}}-{{_component}} creation, status: $status"

      sleep {{status_check_sleep_time}}

      if [[ "$status" == "CREATE_FAILED" ]]; then
        echo "Stack final status: ${status}, raise an error"
        exit 1
      fi

      if [[ "$status" == "CREATE_COMPLETE" ]]; then
          echo "Stack final status: ${status}, no error, continue"
          exit 0
      fi
    done

_delete_base_stack _component: \
    (_delete_base_stack_with_region _component default_region)

_delete_stack _component: \
    (_delete_stack_with_region _component default_region)

_delete_base_stack_with_region _component _region:
    #!{{bash_shebang}}
    echo "=============================== Delete base stack =============================="
    echo "component: {{_component}}"
    echo "region: {{_region}}"
    echo "stack_name: {{base_stack_name}}-{{_component}}"
    echo "--------------------------------------------------------------------------------"

    aws cloudformation \
      --no-cli-pager \
      delete-stack \
      --region {{_region}} \
      --stack-name {{base_stack_name}}-{{_component}}
    echo "--------------------------------------------------------------------------------"

_delete_stack_with_region _component _region:
    #!{{bash_shebang}}
    echo "================================= Delete stack ================================="
    echo "component: {{_component}}"
    echo "region: {{_region}}"
    echo "stack_name: {{main_stack_name}}-{{_component}}"
    echo "--------------------------------------------------------------------------------"

    aws cloudformation \
      --no-cli-pager \
      delete-stack \
      --region {{_region}} \
      --stack-name {{main_stack_name}}-{{_component}}
    echo "--------------------------------------------------------------------------------"

_delete_base_stack_wait _component: \
    (_delete_base_stack_wait_with_region _component default_region)

_delete_stack_wait _component: \
    (_delete_stack_wait_with_region _component default_region)

_delete_base_stack_wait_with_region _component _region:
    #!{{bash_shebang}}
    echo "============================ Check base stack status ==========================="
    echo "component: {{_component}}"
    echo "region: {{_region}}"
    echo "status check sleep time: {{status_check_sleep_time}}"
    echo "stack_name: {{base_stack_name}}-{{_component}}"
    echo "--------------------------------------------------------------------------------"

    echo "Waiting for status..."
    sleep {{status_check_sleep_time}}

    echo "Waiting for status..."
    sleep {{status_check_sleep_time}}

    while : ; do
      status=$(aws cloudformation \
              --no-cli-pager \
              list-stacks \
              --region {{_region}} \
              --output text \
              --query "StackSummaries[?StackName=='{{base_stack_name}}-{{_component}}'][CreationTime,StackStatus]" | \
              sort -r | \
              head -1 | \
              awk '{print $2}')
      echo "Waiting for {{base_stack_name}}-{{_component}} deletion, status: ${status}"
      sleep {{status_check_sleep_time}}

      if [[ -z "$status" ]]; then
        echo "Status is empty, stack {{base_stack_name}}-{{_component}} don't exist?"
        exit 0
      fi

      if [[ "$status" == "DELETE_FAILED" ]]; then
        echo "Stack final status: ${status}, raise an error"
        exit 1
      fi

      if [[ "$status" == "DELETE_COMPLETE" ]]; then
        echo "Stack final status: ${status}, no error, continue"
        exit 0
      fi
    done

_delete_stack_wait_with_region _component _region:
    #!{{bash_shebang}}
    echo "============================ Check base stack status ==========================="
    echo "component: {{_component}}"
    echo "region: {{_region}}"
    echo "status check sleep time: {{status_check_sleep_time}}"
    echo "stack_name: {{main_stack_name}}-{{_component}}"
    echo "--------------------------------------------------------------------------------"

    echo "Waiting for status..."
    sleep {{status_check_sleep_time}}

    echo "Waiting for status..."
    sleep {{status_check_sleep_time}}

    while : ; do
      status=$(aws cloudformation \
              --no-cli-pager \
              list-stacks \
              --region {{_region}} \
              --output text \
              --query "StackSummaries[?StackName=='{{main_stack_name}}-{{_component}}'][CreationTime,StackStatus]" | \
              sort -r | \
              head -1 | \
              awk '{print $2}')
      echo "Waiting for {{main_stack_name}}-{{_component}} deletion, status: ${status}"
      sleep {{status_check_sleep_time}}

      if [[ -z "$status" ]]; then
        echo "Status is empty, stack {{main_stack_name}}-{{_component}} don't exist?"
        exit 0
      fi

      if [[ "$status" == "DELETE_FAILED" ]]; then
        echo "Stack final status: ${status}, raise an error"
        exit 1
      fi

      if [[ "$status" == "DELETE_COMPLETE" ]]; then
        echo "Stack final status: ${status}, no error, continue"
        exit 0
      fi
    done
