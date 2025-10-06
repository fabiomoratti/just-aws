# ----------------------------------------------------------------------------------------------------------------------
# Documentation to be written
# ----------------------------------------------------------------------------------------------------------------------

[group('Change Set')]
[doc('Create a changeset for the base component, using the local parameter file; the changes will be the difference between the local template and the deployed one and any changes in parameters values')]
create_base_change_set _component: \
    (_create_base_change_set _component)


[group('Change Set')]
[doc('Create a changeset for the base component, without a parameter file; the changes will be the difference between the local template and the deployed one')]
create_base_change_set_no_param _component: \
    (_create_change_set_no_param _component)


[group('Change Set')]
[doc('Create a changeset for the component, using the local parameter file; the changes will be the difference between the local template and the deployed one and any changes in parameters values')]
create_change_set _component: \
    (_create_change_set _component)


[group('Change Set')]
[doc('Create a changeset for the component, without a parameter file; the changes will be the difference between the local template and the deployed one')]
create_change_set_no_param _component: \
    (_create_change_set_no_param _component)


_create_base_change_set _component: \
    (_copy_base_template _component) \
    (_validate_base_template _component) \
    (_create_base_change_set_with_region _component default_region)


_create_base_change_set_no_param _component: \
    (_copy_base_template _component) \
    (_validate_base_template _component) \
    (_create_base_change_set_no_param_with_region _component default_region)


_create_change_set _component: \
    (_copy_template _component) \
    (_validate_template _component) \
    (_create_change_set_with_region _component default_region)


_create_change_set_no_param _component: \
    (_copy_template _component) \
    (_validate_template _component) \
    (_create_change_set_no_param_with_region _component default_region)


_create_base_change_set_with_region _component _region:
    #!{{bash_shebang}}
    change_set_name=change-set-$(date "+%Y-%m-%d-%H-%M")
    echo "============================= Create base change set ============================"
    echo "component: {{_component}}"
    echo "region: {{_region}}"
    echo "stack_name: {{base_stack_name}}-{{_component}}"
    echo "change_set_name: ${change_set_name}"
    echo "template_url: {{stack_bucket_endpoint}}/{{stack_bucket}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.yaml"
    echo "parameters_dir: {{parameters_dir}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.json"
    echo "--------------------------------------------------------------------------------"


    aws cloudformation \
      create-change-set \
      --no-cli-pager \
      --region {{_region}} \
      --stack-name {{main_stack_name}}-{{_component}} \
      --change-set-name ${change_set_name} \
      --template-url {{stack_bucket_endpoint}}/{{stack_bucket}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.yaml \
      --capabilities CAPABILITY_NAMED_IAM \
      --parameters file://{{parameters_dir}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.json


_create_base_change_set_no_param_with_region _component _region:
    #!{{bash_shebang}}
    change_set_name=change-set-$(date "+%Y-%m-%d-%H-%M")
    echo "===================== Create change base set (no parameters) ===================="
    echo "component: {{_component}}"
    echo "region: {{_region}}"
    echo "stack_name: {{base_stack_name}}-{{_component}}"
    echo "change_set_name: ${change_set_name}"
    echo "template_url: {{stack_bucket_endpoint}}/{{stack_bucket}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.yaml"
    echo "--------------------------------------------------------------------------------"

    aws cloudformation \
      create-change-set \
      --no-cli-pager \
      --region {{_region}} \
      --stack-name {{main_stack_name}}-{{_component}} \
      --change-set-name ${change_set_name} \
      --template-url {{stack_bucket_endpoint}}/{{stack_bucket}}/{{base_stack_name}}/{{base_stack_name}}-{{_component}}.yaml \
      --capabilities CAPABILITY_NAMED_IAM


_create_change_set_with_region _component _region:
    #!{{bash_shebang}}
    change_set_name=change-set-$(date "+%Y-%m-%d-%H-%M")
    echo "=============================== Create change set =============================="
    echo "component: {{_component}}"
    echo "region: {{_region}}"
    echo "stack_name: {{main_stack_name}}-{{_component}}"
    echo "change_set_name: ${change_set_name}"
    echo "template_url: {{stack_bucket_endpoint}}/{{stack_bucket}}/{{main_stack_name}}/{{main_stack_name}}-{{_component}}.yaml"
    echo "parameters_dir: {{parameters_dir}}/{{base_stack_name}}/{{env_stack_name}}/{{main_stack_name}}-{{_component}}.json"
    echo "--------------------------------------------------------------------------------"

    aws cloudformation \
      create-change-set \
      --no-cli-pager \
      --region {{_region}} \
      --stack-name {{main_stack_name}}-{{_component}} \
      --change-set-name ${change_set_name} \
      --template-url {{stack_bucket_endpoint}}/{{stack_bucket}}/{{main_stack_name}}/{{main_stack_name}}-{{_component}}.yaml \
      --capabilities CAPABILITY_NAMED_IAM \
      --parameters file://{{parameters_dir}}/{{base_stack_name}}/{{env_stack_name}}/{{main_stack_name}}-{{_component}}.json


_create_change_set_no_param_with_region _component _region:
    #!{{bash_shebang}}
    change_set_name=change-set-$(date "+%Y-%m-%d-%H-%M")
    echo "======================= Create change set (no parameters) ======================"
    echo "component: {{_component}}"
    echo "region: {{_region}}"
    echo "stack_name: {{main_stack_name}}-{{_component}}"
    echo "change_set_name: ${change_set_name}"
    echo "template_url: {{stack_bucket_endpoint}}/{{stack_bucket}}/{{main_stack_name}}/{{main_stack_name}}-{{_component}}.yaml"
    echo "--------------------------------------------------------------------------------"

    aws cloudformation \
      create-change-set \
      --no-cli-pager \
      --region {{_region}} \
      --stack-name {{main_stack_name}}-{{_component}} \
      --change-set-name ${change_set_name} \
      --template-url {{stack_bucket_endpoint}}/{{stack_bucket}}/{{main_stack_name}}/{{main_stack_name}}-{{_component}}.yaml \
      --capabilities CAPABILITY_NAMED_IAM
