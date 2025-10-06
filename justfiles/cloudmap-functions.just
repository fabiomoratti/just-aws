# ----------------------------------------------------------------------------------------------------------------------
# Documentation to be written
# ----------------------------------------------------------------------------------------------------------------------

_list_cloudmap_instances _service_name:
    #!{{bash_shebang}}
    echo "============================ CloudMap instance list ============================"
    echo "service_name: {{_service_name}}"
    echo "service description: {{_service_name}}-{{main_stack_name}}-cloudmap"
    echo "--------------------------------------------------------------------------------"

    service_id=$(aws servicediscovery \
      --no-cli-pager \
      list-services \
      --query "Services[?Description=='{{_service_name}}-{{main_stack_name}}-cloudmap'].Id[]|[0]" | sed -e 's/"//g')
    echo "service_id for {{_service_name}}: ${service_id}"

    instances_list=($(aws servicediscovery \
      --no-cli-pager \
      list-instances \
      --service-id ${service_id} \
      --query "Instances[].Id" | \
      sed -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/,/ /g'))

    echo "================================= Instance list ================================"
    for instance_id in ${instances_list[@]}; do
      echo "Id: ${instance_id}"
    done
    echo "--------------------------------------------------------------------------------"


_deregister_all_instances _service_name:
    #!{{bash_shebang}}
    echo "=====================--= Deregister images from CloudMap ======================="
    echo "service_name: {{_service_name}}"
    echo "service description: {{_service_name}}-{{main_stack_name}}-cloudmap"
    echo "--------------------------------------------------------------------------------"

    service_id=$(aws servicediscovery \
      --no-cli-pager \
      list-services \
      --query "Services[?Description=='{{_service_name}}-{{main_stack_name}}-cloudmap'].Id[]|[0]" | sed -e 's/"//g')
    echo "service_id for {{_service_name}}: ${service_id}"

    instances_list=($(aws servicediscovery \
      --no-cli-pager \
      list-instances \
      --service-id ${service_id} \
      --query "Instances[].Id" |
      sed -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/,/ /g'))
    echo "instances_list: ${instances_list}"

    echo "================================= Instance list ================================"
    for instance_id in ${instances_list[@]}; do
      echo "Id: ${instance_id}"
    done
    echo "--------------------------------------------------------------------------------"

    echo "================================= Deregistration ==============================="
    for instance_id in ${instances_list[@]}; do
      echo "Deregistering instance: ${instance_id}"

      aws servicediscovery \
        --no-cli-pager \
        deregister-instance \
        --service-id ${service_id} \
        --instance-id ${instance_id}
    done
    echo "--------------------------------------------------------------------------------"


_deregister_non_running_instances _service_name:
    #!{{bash_shebang}}
    echo "====================== Deregister non running images from CloudMap ======================"
    echo "service_name: {{_service_name}}"
    echo "service description: {{_service_name}}-{{main_stack_name}}-cloudmap"
    echo "--------------------------------------------------------------------------------"

    service_id=$(aws servicediscovery \
      --no-cli-pager \
      list-services \
      --query "Services[?Description=='{{_service_name}}-{{main_stack_name}}-cloudmap'].Id[]|[0]" | sed -e 's/"//g')
    echo "service_id for {{_service_name}}: ${service_id}"

    instances_list=($(aws servicediscovery \
      --no-cli-pager \
      list-instances \
      --service-id ${service_id} \
      --query "Instances[].Id" |
      sed -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/,/ /g'))

    for instance_id in ${instances_list[@]}; do
      echo "================================================================================"
      echo "Instance Id: ${instance_id}"

      instance_state=$(aws ec2 \
        --no-cli-pager \
        describe-instance-status \
        --include-all-instances \
        --instance-ids ${instance_id} \
        --query "InstanceStatuses[].InstanceState.Name[]|[0]" |
        sed -e 's/"//g')
      echo "Instance state: ${instance_state}"

      if [[ "$instance_state" != "running" ]]; then
        echo "Deregister instance ${instance_id}"
        aws servicediscovery \
          --no-cli-pager \
          deregister-instance \
          --service-id ${service_id} \
          --instance-id ${instance_id}
      fi
      echo "--------------------------------------------------------------------------------"
    done
