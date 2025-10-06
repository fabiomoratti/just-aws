# ----------------------------------------------------------------------------------------------------------------------
# TBW
# ----------------------------------------------------------------------------------------------------------------------

list_all_parameters: \
    (_list_parameters "non-prod") \
    (_list_parameters "prod")
list_prod_parameters: (_list_parameters "prod")
list_non_prod_parameters: (_list_parameters "non-prod")

list_prod_parameters_with_values: (_list_parameters_with_values "prod")
list_non_prod_parameters_with_values: (_list_parameters_with_values "non-prod")


add_parameter _env_type _parameter_group _parameter_name _parameter_value:
    #!{{bash_shebang}}
    # set -euxo pipefail

    env_type={{_env_type}}
    if [[ "${env_type}" != "prod" && "${env_type}" != "non-prod" ]]; then
        echo "env type should be either 'prod' or 'non-prod'"
        exit 1
    fi

    aws ssm \
        put-parameter \
        --no-cli-pager \
        --name " /env/{{_env_type}}/{{_parameter_group}}/{{_parameter_name}}" \
        --value "{{_parameter_value}}" \
        --type "SecureString" \
        --tier "Standard" \
        --overwrite

delete_parameter _env_type _parameter_group _parameter_name:
    #!{{bash_shebang}}
    # set -euxo pipefail

    env_type={{_env_type}}
    if [[ "${env_type}" != "prod" && "${env_type}" != "non-prod" ]]; then
        echo "env type should be either 'prod' or 'non-prod'"
        exit 1
    fi

    aws ssm \
        delete-parameter \
        --no-cli-pager \
        --name " /env/{{_env_type}}/{{_parameter_group}}/{{_parameter_name}}"

get_parameter _env_type _parameter_group _parameter_name:
    #!{{bash_shebang}}
    # set -euxo pipefail

    env_type={{_env_type}}
    if [[ "${env_type}" != "prod" && "${env_type}" != "non-prod" ]]; then
        echo "env type should be either 'prod' or 'non-prod'"
        exit 1
    fi

    aws ssm \
        get-parameter \
        --no-cli-pager \
        --with-decryption \
        --query "Parameter.{Name:Name,Value:Value}" \
        --name " /env/{{_env_type}}/{{_parameter_group}}/{{_parameter_name}}"

_list_parameters _env_type:
    #!{{bash_shebang}}
    # set -euxo pipefail
    echo "----------------------------"
    echo "{{_env_type}} parameter list"
    echo "----------------------------"
    aws ssm \
        get-parameters-by-path \
        --no-cli-pager \
        --recursive \
        --query "Parameters[].Name" \
        --path " /env/{{_env_type}}"

_list_parameters_with_values _env_type:
    #!{{bash_shebang}}
    # set -euxo pipefail
    echo "----------------------------"
    echo "{{_env_type}} parameter list"
    echo "----------------------------"
    aws ssm \
        get-parameters-by-path \
        --no-cli-pager \
        --recursive \
        --with-decryption \
        --query "Parameters[].{Name:Name,Value:Value}" \
        --path " /env/{{_env_type}}"
