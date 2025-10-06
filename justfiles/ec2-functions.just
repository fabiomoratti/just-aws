# ----------------------------------------------------------------------------------------------------------------------
# Documentation to be written
# ----------------------------------------------------------------------------------------------------------------------

[group('EC2 - Instances')]
[doc('Shortcut to connect to and EC2 instance, using ec2-instance-connect utility and the instance id')]
c _instance_id: (connect _instance_id)

[group('EC2 - Instances')]
[doc('Connect to and EC2 instance, using ec2-instance-connect utility and the instance id')]
connect _instance_id:
    aws ec2-instance-connect ssh --os-user {{os_user}} --instance-id {{_instance_id}}

[group('EC2 - Instances')]
[doc('Shortcut to list available intances - uses the main_stack_name variable to select relevant instances')]
lsi: list_instances

[group('EC2 - Instances')]
[doc('List available intances - uses the main_stack_name variable to select relevant instances')]
list_instances: (_print_stack_ec2_instances main_stack_name)

[group('EC2 - Instances')]
[doc('Shortcut to list intances - uses the main_stack_name variable to select relevant instances')]
describe_instance instance_id: (_describe_instances instance_id)

_print_stack_ec2_instances _stack_name_prefix:
    #!{{bash_shebang}}
    echo "Printing instances for ASGs in stack {{_stack_name_prefix}}"
    aws autoscaling \
      --no-cli-pager \
      describe-auto-scaling-groups \
      --query "AutoScalingGroups[?starts_with(AutoScalingGroupName,'{{_stack_name_prefix}}')].\
        {ASGName:AutoScalingGroupName,\
        DesiredCapacity:DesiredCapacity, \
        Instances:Instances[*].\
        {Template:LaunchTemplate.LaunchTemplateName,\
        Id:InstanceId}}"
    echo "--------------------------------------------------------------------------------"
    echo "Use 'just connect <instance-id>' to connect to the instance"

_describe_instances _instance_id:
    #!{{bash_shebang}}
    echo "Printing instance details for instance {{_instance_id}}"
    aws ec2 \
      --no-cli-pager \
      describe-instances \
      --query=\
        "Reservations[].Instances[].\
          {\
              InstanceId:InstanceId,\
              Name:Tags[?Key=='Name'].Value|[0],\
              PrivateIpAddress:PrivateIpAddress,\
              PublicIpAddress:PublicIpAddress\
          }" \
      --instance-ids {{_instance_id}}
    echo "--------------------------------------------------------------------------------"

_set_desired_capacity _component _capacity:
    #!{{bash_shebang}}
    echo "============================= Set desired capacity ============================="
    echo "stack_name: {{main_stack_name}}"
    echo "component: {{_component}}"
    echo "capacity: {{_capacity}}"
    echo "--------------------------------------------------------------------------------"

    asg_name=$(aws autoscaling \
      --no-cli-pager \
      describe-auto-scaling-groups \
      --query "AutoScalingGroups[?starts_with(AutoScalingGroupName,'{{main_stack_name}}') && \
        contains(AutoScalingGroupName,'{{_component}}')].\
        AutoScalingGroupName | [0]" |
      sed -e 's/"//g')
    echo "Auto Scaling Group Name: ${asg_name}"

    aws autoscaling \
      --no-cli-pager \
      set-desired-capacity \
      --auto-scaling-group-name ${asg_name} \
      --desired-capacity {{_capacity}}

_print_version _component_name:
    #!{{bash_shebang}}

    asg_name=$(aws autoscaling \
        describe-auto-scaling-groups \
        --no-cli-pager \
        --query "AutoScalingGroups[?starts_with(AutoScalingGroupName,'{{main_stack_name}}') && \
        contains(AutoScalingGroupName,'build-server')].AutoScalingGroupName|[0]" | \
        sed -e 's/"//g')

    instance_id=$(aws autoscaling \
        describe-auto-scaling-groups \
        --no-cli-pager \
        --query "AutoScalingGroups[?AutoScalingGroupName=='${asg_name}'].Instances[0].InstanceId|[0]" | \
        sed -e 's/"//g')

    instance_private_address=$(aws ec2 \
        describe-instances \
        --no-cli-pager \
        --query="Reservations[].Instances[].PrivateIpAddress|[0]" \
        --instance-ids ${INSTANCE_ID} | \
        sed -e 's/"//g')

    temp_key_file=tmp-key-{{uuid()}}

    ssh-keygen -f ${temp_key_file} -P "" -t rsa 2>&1 > /dev/null

    aws ec2-instance-connect \
        send-ssh-public-key \
        --instance-id ${instance_id} \
        --instance-os-user {{os_user}} \
        --ssh-public-key file://${temp_key_file}.pub 2>&1 > /dev/null

    version_on_build_server=$(ssh {{os_user}}@${instance_private_address} \
        -o ProxyCommand="aws ec2-instance-connect open-tunnel --instance-id ${instance_id}" \
        -o StrictHostKeyChecking=no \
        -i ${temp_key_file} \
        "grep '{{_component_name}}=' versions.txt | sed -e 's/.*=//'")

    rm ${temp_key_file}
    rm ${temp_key_file}.pub

    version_on_parameter_store=$(aws ssm \
        get-parameter \
        --no-cli-pager \
        --with-decryption \
        --query "Parameter.{Name:Name,Value:Value}" \
        --name " /version/{{stack_type}}/{{base_stack_name}}/{{env_stack_name}}/{{_component_name}}" | \
        jq .Value | \
        sed -e 's/"//g')

    echo "{{_component_name}} version in parameter store is ${version_on_parameter_store}"
    echo "{{_component_name}} version on build server is ${version_on_build_server}"

_set_version _component_name _new_version:
    #!{{bash_shebang}}

    asg_name=$(aws autoscaling \
        describe-auto-scaling-groups \
        --no-cli-pager \
        --query "AutoScalingGroups[?starts_with(AutoScalingGroupName,'{{main_stack_name}}') && \
        contains(AutoScalingGroupName,'build-server')].AutoScalingGroupName|[0]" | \
        sed -e 's/"//g')

    instance_id=$(aws autoscaling \
        describe-auto-scaling-groups \
        --no-cli-pager \
        --query "AutoScalingGroups[?AutoScalingGroupName=='${asg_name}'].Instances[0].InstanceId|[0]" | \
        sed -e 's/"//g')

    instance_private_address=$(aws ec2 \
        describe-instances \
        --no-cli-pager \
        --query="Reservations[].Instances[].PrivateIpAddress|[0]" \
        --instance-ids ${INSTANCE_ID} | \
        sed -e 's/"//g')

    temp_key_file=tmp-key-{{uuid()}}

    ssh-keygen -f ${temp_key_file} -P "" -t rsa 2>&1 > /dev/null

    aws ec2-instance-connect \
        send-ssh-public-key \
        --instance-id ${instance_id} \
        --instance-os-user {{os_user}} \
        --ssh-public-key file://${temp_key_file}.pub 2>&1 > /dev/null

    ssh {{os_user}}@${instance_private_address} \
        -o ProxyCommand="aws ec2-instance-connect open-tunnel --instance-id ${instance_id}" \
        -o StrictHostKeyChecking=no \
        -i ${temp_key_file} \
        "sed -i -e '/{{_component_name}}=/{s/=.*$/={{_new_version}}/}' ~/versions.txt && echo 'Version file is: ' && cat ~/versions.txt"

    rm ${temp_key_file}
    rm ${temp_key_file}.pub

_start_instance_refresh _component:
    #!{{bash_shebang}}
    echo "============================= Start instance refresh ============================="
    echo "stack_name: {{main_stack_name}}"
    echo "component: {{_component}}"
    echo "--------------------------------------------------------------------------------"

    asg_name=$(aws autoscaling \
        describe-auto-scaling-groups \
        --no-cli-pager \
        --query "AutoScalingGroups[?starts_with(AutoScalingGroupName,'{{main_stack_name}}') && \
        contains(AutoScalingGroupName,'{{_component}}')].AutoScalingGroupName|[0]" | \
        sed -e 's/"//g')
    echo "asg_name: ${asg_name}"

    aws autoscaling \
        start-instance-refresh \
        --no-cli-pager \
        --auto-scaling-group-name ${asg_name}

_execute_remote_command _component _command:
    #!{{bash_shebang}}
    echo "============================= Execute remote command ============================="
    echo "stack_name: {{main_stack_name}}"
    echo "component: {{_component}}"
    echo "command: {{_command}}"
    echo "--------------------------------------------------------------------------------"

    asg_name=$(aws autoscaling \
        describe-auto-scaling-groups \
        --no-cli-pager \
        --query "AutoScalingGroups[?starts_with(AutoScalingGroupName,'{{main_stack_name}}') && \
        contains(AutoScalingGroupName,'{{_component}}')].AutoScalingGroupName|[0]" | \
        sed -e 's/"//g')
    echo "asg_name: ${asg_name}"

    instance_id=$(aws autoscaling \
        describe-auto-scaling-groups \
        --no-cli-pager \
        --query "AutoScalingGroups[?AutoScalingGroupName=='${asg_name}'].Instances[0].InstanceId|[0]" | \
        sed -e 's/"//g')
    echo "instance_id: ${instance_id}"

    instance_private_address=$(aws ec2 \
        describe-instances \
        --no-cli-pager \
        --query="Reservations[].Instances[].PrivateIpAddress|[0]" \
        --instance-ids ${INSTANCE_ID} | \
        sed -e 's/"//g')
    echo "instance_private_address=${instance_private_address}"

    temp_key_file=tmp-key-{{uuid()}}
    echo "temp_key_file=${temp_key_file}"

    echo "Creating temporary key"
    ssh-keygen -f ${temp_key_file} -P "" -t rsa

    echo "Provisioning temporary key to instance ${instance_id}"
    aws ec2-instance-connect \
        send-ssh-public-key \
        --instance-id ${instance_id} \
        --instance-os-user {{os_user}} \
        --ssh-public-key file://${temp_key_file}.pub
    echo "The key will be on the instance for 60 seconds"

    echo "Executing command {{_command}} on instance ${instance_id} with address ${instance_private_address}"
    ssh {{os_user}}@${instance_private_address} \
        -o ProxyCommand="aws ec2-instance-connect open-tunnel --instance-id ${instance_id}" \
        -o StrictHostKeyChecking=no \
        -i ${temp_key_file} \
        "{{_command}}"

    echo "Cleaning up"
    rm ${temp_key_file}
    rm ${temp_key_file}.pub


c2 _instance_id:
    #!{{bash_shebang}}
    echo "============================= Execute remote command ============================="
    echo "stack_name: {{main_stack_name}}"
    echo "instance_id: {{_instance_id}}"
    echo "--------------------------------------------------------------------------------"

    instance_private_address=$(aws ec2 \
        describe-instances \
        --no-cli-pager \
        --query="Reservations[].Instances[].PrivateIpAddress|[0]" \
        --instance-ids ${INSTANCE_ID} | \
        sed -e 's/"//g')
    echo "instance_private_address=${instance_private_address}"

    temp_key_file=tmp-key-{{uuid()}}

    ssh-keygen -f ${temp_key_file} -P "" -t rsa

    aws ec2-instance-connect \
        send-ssh-public-key \
        --instance-id {{_instance_id}} \
        --instance-os-user {{os_user}} \
        --ssh-public-key file://${temp_key_file}.pub

    aws ec2-instance-connect ssh --os-user {{os_user}} --instance-id {{_instance_id}} --private-key-file ${temp_key_file}

    rm ${temp_key_file}
    rm ${temp_key_file}.pub
