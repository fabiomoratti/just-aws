# ----------------------------------------------------------------------------------------------------------------------
# Documentation to be written
# ----------------------------------------------------------------------------------------------------------------------

[group('Env')]
[doc('Short version of the print_current_env command')]
pce: print_current_env

[group('Env')]
[doc('Print the current env (default and actually loaded environment variables)')]
print_current_env:
    #!{{bash_shebang}}
    echo "--------------------------------------------------------------------------"
    echo "Default env Just variables (will use these if no JUST_ENV variable is set)"
    echo "--------------------------------------------------------------------------"
    echo "default_aws_profile: {{default_aws_profile}}"
    echo "default_stack_type: {{default_stack_type}}"
    echo "default_base_stack_name: {{default_base_stack_name}}"
    echo "default_env_stack_name: {{default_env_stack_name}}"
    echo ""
    echo ""

    echo "-----------------------------------------------------------------------------------------------"
    echo "env Just variables (will use these with the current configuration - default or loaded from env)"
    echo "-----------------------------------------------------------------------------------------------"
    echo ""

    if [ ! -z ${JUST_COMMON+x} ]; then
      echo "JUST_COMMON is ${JUST_COMMON}, loading common settings from '${JUST_COMMON}.just'"
      echo ""
    fi

    if [ -z ${JUST_ENV+x} ]; then
      echo "JUST_ENV not set: will use default values, use 'just list_envs' for available envs"
    else
      echo "Loaded ENV ${JUST_ENV}"
    fi
    echo ""

    echo "aws_profile: {{aws_profile}}"
    echo "stack_type: {{stack_type}}"
    echo "base_stack_name: {{base_stack_name}}"
    echo "env_stack_name: {{env_stack_name}}"
    echo "main_stack_name: {{main_stack_name}}"
    echo ""
    echo ""


[group('Env')]
[doc('Print project-related env variables')]
print_common_env:
    #!{{bash_shebang}}
    echo "--------------------------------------"
    echo "Other - project related Just variables"
    echo "--------------------------------------"
    if [ -z ${JUST_COMMON+x} ]; then
      echo "JUST_COMMON not set: will use default values in 'common.just' - this is the usual behaviour"
    else
      echo "Loaded common settings in ${JUST_COMMON}"
    fi
    echo ""
    echo "status_check_sleep_time: {{status_check_sleep_time}}"
    echo "parameters_dir: {{parameters_dir}}"
    echo "stack_token_post_fix: {{stack_token_post_fix}}"
    echo "stack_bucket_endpoint: {{stack_bucket_endpoint}}"
    echo "stack_bucket: {{stack_bucket}}"
    echo ""
    echo ""

[group('Env')]
[doc('Print environment variables, loaded from the dot-env file')]
print_environment_variables:
    #!{{bash_shebang}}
    echo "--------------------------------------------"
    echo "Environment Variables (loaded from JUST_ENV)"
    echo "--------------------------------------------"

    if [ -z ${JUST_ENV_AWS_PROFILE+x} ]; then
      echo "JUST_ENV_AWS_PROFILE not set will use default value '{{default_aws_profile}}'"
    else
      echo "JUST_ENV_AWS_PROFILE: ${JUST_ENV_AWS_PROFILE}"
    fi

    if [ -z ${JUST_ENV_STACK_TYPE+x} ]; then
      echo "JUST_ENV_STACK_TYPE not set will use default value '{{default_stack_type}}'"
    else
      echo "JUST_ENV_STACK_TYPE: ${JUST_ENV_STACK_TYPE}"
    fi

    if [ -z ${JUST_ENV_BASE_STACK_NAME+x} ]; then
      echo "JUST_ENV_BASE_STACK_NAME not set will use default value '{{default_base_stack_name}}'"
    else
      echo "JUST_ENV_BASE_STACK_NAME: ${JUST_ENV_BASE_STACK_NAME}"
    fi

    if [ -z ${JUST_ENV_ENV_STACK_NAME+x} ]; then
      echo "JUST_ENV_ENV_STACK_NAME not set will use default value '{{default_env_stack_name}}'"
    else
      echo "JUST_ENV_ENV_STACK_NAME: ${JUST_ENV_ENV_STACK_NAME}"
    fi

    echo ""
    if [ -z ${JUST_ENV+x} ]; then
      echo "JUST_ENV not set: will use default values, use 'just list_envs' for available envs"
    else
      echo "Loaded ENV ${JUST_ENV}"
    fi
    echo ""
    echo ""

[group('Env')]
[doc('List the available environments, defined in envs folder')]
list_envs:
    #!{{bash_shebang}}
    AVAILABLE_ENVS=($(ls -1 envs/*.env))
    echo "The follwing envs are available:"
    for ENV in ${AVAILABLE_ENVS[@]}; do
        ENV_NAME=${ENV#envs/}
        ENV_NAME=${ENV_NAME%.env}
        echo " - ${ENV_NAME}"
        echo "   Activate with (Win / Linux - Mac):"
        echo "   set \"JUST_ENV=${ENV_NAME}\" "
        echo "   export JUST_ENV=${ENV_NAME} "
        echo ""
    done
    if [ -z ${JUST_ENV+x} ]; then
      echo "JUST_ENV not set using default values, use 'just print_current_env' list them"
    else
      echo "Loaded ENV ${JUST_ENV}"
    fi

[group('Env')]
[doc('List the available common settings, defined in envs folder')]
list_commons:
    #!{{bash_shebang}}
    AVAILABLE_COMMONS=($(ls -1 envs/common*.just | grep -v common.just))
    echo "The follwing additional common settings are available - Note: normally you should use the default common:"
    for COMMON in ${AVAILABLE_COMMONS[@]}; do
        COMMON_NAME=${COMMON#envs/}
        COMMON_NAME=${COMMON_NAME%.just}
        echo " - ${COMMON_NAME}"
        echo "   Activate with (Win / Linux - Mac):"
        echo "   set \"JUST_COMMON=${COMMON_NAME}\" "
        echo "   export JUST_COMMON=${COMMON_NAME} "
        echo ""
    done

    if [ -z ${JUST_COMMON+x} ]; then
      echo "JUST_COMMON not set: will use default values in 'common.just' - this is the usual behaviour"
    else
      echo "Loaded common settings in ${JUST_COMMON}"
    fi
    echo ""

clean_known_hosts_file _line_number:
    #!{{bash_shebang}}
    kh_file1="{{home_directory()}}/.ssh/known_hosts"
    echo "kh_file1: ${kh_file1}"
    echo "HOME: ${HOME}"
    kh_file2="${HOME}/.ssh/known_hosts"
    ls ${kh_file2}
    sed -i -e '{{_line_number}}d' ${kh_file2}
