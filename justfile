
# ----------------------------------------------------------------------------------------------------------------------
# Note: I've encountered some unexpected behaviour in Windows running shebang recipes using '#bash' directly without "/"
# see: https://github.com/casey/just/issues/2143
# The details are pending investigation and apparently the variable export workarount mentioned in the issue does not
# seem to work anymore.
# The main reason to use a shebang without "/" was to avoid using cygpath to avoid having cygwin installed.
# I've since learned that Git distribution contains cygpath so the solution is to add the path to the git "cygpath"
# executable so it's not necessary to install cygwin.
# I also use the Git bash executable so make sure the cmd environment running just has these two paths in the PATH
# variable (your mileage may vary depending where git is installed):
# - C:\Program Files\Git\bin (git bash executable)
# - C:\Program Files\Git\usr\bin (cygpath executable)
#
# See also:
# - https://just.systems/man/en/prerequisites.html#prerequisites
# - https://just.systems/man/en/paths-on-windows.html#paths-on-windows
# - https://just.systems/man/en/safer-bash-shebang-recipes.html#shebang-recipe-execution-on-windows
# - https://just.systems/man/en/script-recipes.html#script-recipes
# - https://just.systems/man/en/script-and-shebang-recipe-temporary-files.html
# export JUST_DUMMY_VARIABLE := "JUST_DUMMY_VALUE"
# ----------------------------------------------------------------------------------------------------------------------
bash_shebang := if os() == 'windows' {
	'/bin/bash'
} else {
	'/bin/bash'
}

bash_options_for_just := 'set -euxo pipefail'

bash_noprint := 'set +x'



install target_dir=("install-test"): \
    (copy_files target_dir) \
    (setup_common target_dir) \
    (setup_additional_common target_dir) \
    (setup_environment target_dir) \
    (setup_parameters target_dir) \
    (setup_additional_parameters target_dir)

setup_common target_dir=("install-test"):
    #!{{bash_shebang}}
    {{bash_options_for_just}}
    {{bash_noprint}}

    target_dir={{target_dir}}
    echo "Installing in: ${target_dir}"

    # common values
    while true; do
        echo "==================="
        echo "Setup common values"
        echo "==================="

        read -rp "AWS region [eu-central-1]: " default_region
        default_region=${default_region:-eu-central-1}

        read -rp "Stack template bucket [mybucket]: " stack_bucket
        stack_bucket=${stack_bucket:-mybucket}

        default_bucket_endpoint="https://s3.${default_region}.amazonaws.com"
        read -rp "Bucket endpoint - depends on the region where the bucket has been created [${default_bucket_endpoint}]: " stack_bucket_endpoint
        stack_bucket_endpoint=${stack_bucket_endpoint:-${default_bucket_endpoint}}

        read -rp "OS User [ec2user]: " os_user
        os_user=${os_user:-ec2user}

        echo "Selected values are:"
        echo "---------------------------------------------------"
        echo "default_region: ${default_region}"
        echo "stack_bucket: ${stack_bucket}"
        echo "default_bucket_endpoint: ${default_bucket_endpoint}"
        echo "os_user: ${os_user}"
        echo "---------------------------------------------------"

        read -rp "Confirm? [y/N]: " confirm
        confirm=${confirm:-N}
        case "${confirm,,}" in
            y|yes)
              break
              ;;
            *)
              echo "Let's try again."
              ;;
          esac
    done

    cp envs/common-template.just ${target_dir}/envs/common.just
    sed -i -e "s|____default_region____|${default_region}|" ${target_dir}/envs/common.just
    sed -i -e "s|____stack_bucket____|${stack_bucket}|" ${target_dir}/envs/common.just
    sed -i -e "s|____stack_bucket_endpoint____|${stack_bucket_endpoint}|" ${target_dir}/envs/common.just
    sed -i -e "s|____os_user____|${os_user}|" ${target_dir}/envs/common.just

setup_additional_common target_dir=("install-test"):
    #!{{bash_shebang}}
    {{bash_options_for_just}}
    {{bash_noprint}}

    target_dir={{target_dir}}
    echo "Installing in: ${target_dir}"

    read -rp "Setup an additional common? [y/N]: " confirm
    confirm=${confirm:-N}
    case "${confirm,,}" in
        y|yes)
          ;;
        *)
          exit 0
          ;;
      esac

    # common values
    while true; do
        echo "==================="
        echo "Setup common values"
        echo "==================="

        read -rp "Additional common name [example]: " common_name
        common_name=${common_name:-example}

        read -rp "AWS region [eu-central-1]: " default_region
        default_region=${default_region:-eu-central-1}

        read -rp "Stack template bucket [mybucket]: " stack_bucket
        stack_bucket=${stack_bucket:-mybucket}

        default_bucket_endpoint="https://s3.${default_region}.amazonaws.com"
        read -rp "Bucket endpoint - depends on the region where the bucket has been created [${default_bucket_endpoint}]: " stack_bucket_endpoint
        stack_bucket_endpoint=${stack_bucket_endpoint:-${default_bucket_endpoint}}

        read -rp "OS User [ec2user]: " os_user
        os_user=${os_user:-ec2user}

        echo "Selected values are:"
        echo "---------------------------------------------------"
        echo "common_name: ${common_name}"
        echo "default_region: ${default_region}"
        echo "stack_bucket: ${stack_bucket}"
        echo "default_bucket_endpoint: ${default_bucket_endpoint}"
        echo "os_user: ${os_user}"
        echo "---------------------------------------------------"

        read -rp "Confirm? [y/N]: " confirm
        confirm=${confirm:-N}
        case "${confirm,,}" in
            y|yes)
              break
              ;;
            *)
              echo "Let's try again."
              ;;
          esac
    done

    cp envs/common-template.just ${target_dir}/envs/common-${common_name}.just
    sed -i -e "s|____default_region____|${default_region}|" ${target_dir}/envs/common-${common_name}.just
    sed -i -e "s|____stack_bucket____|${stack_bucket}|" ${target_dir}/envs/common-${common_name}.just
    sed -i -e "s|____stack_bucket_endpoint____|${stack_bucket_endpoint}|" ${target_dir}/envs/common-${common_name}.just
    sed -i -e "s|____os_user____|${os_user}|" ${target_dir}/envs/common-${common_name}.just

setup_environment target_dir=("install-test"):
    #!{{bash_shebang}}
    {{bash_options_for_just}}
    {{bash_noprint}}

    target_dir={{target_dir}}
    echo "Installing in: ${target_dir}"

    # default environment
    while true; do
        echo "========================="
        echo "Setup default environment"
        echo "========================="

        read -rp "Default aws profile [default]: " default_aws_profile
        default_aws_profile=${default_aws_profile:-default}

        read -rp "Default stack type (reccomended values are development, staging, production)[development]: " default_stack_type
        default_stack_type=${default_stack_type:-development}

        read -rp "Base stack name [MyProject]: " default_base_stack_name
        default_base_stack_name=${default_base_stack_name:-MyProject}

        read -rp "Stack name [MyProject1]: " default_env_stack_name
        default_env_stack_name=${default_env_stack_name:-MyProject1}

        echo "Selected values are:"
        echo "---------------------------------------------------"
        echo "default_aws_profile: ${default_aws_profile}"
        echo "default_stack_type: ${default_stack_type}"
        echo "default_base_stack_name: ${default_base_stack_name}"
        echo "default_env_stack_name: ${default_env_stack_name}"
        echo "---------------------------------------------------"

        read -rp "Confirm? [y/N]: " confirm
        confirm=${confirm:-N}
        case "${confirm,,}" in
            y|yes)
              break
              ;;
            *)
              echo "Let's try again."
              ;;
          esac
    done

    cp envs/default-template.just ${target_dir}/envs/default.just
    sed -i -e "s|____default_aws_profile____|${default_aws_profile}|" ${target_dir}/envs/default.just
    sed -i -e "s|____default_stack_type____|${default_stack_type}|" ${target_dir}/envs/default.just
    sed -i -e "s|____default_base_stack_name____|${default_base_stack_name}|" ${target_dir}/envs/default.just
    sed -i -e "s|____default_env_stack_name____|${default_env_stack_name}|" ${target_dir}/envs/default.just

    # Create additional example env files
    example_env1="${target_dir}/envs/${default_base_stack_name}Staging-${default_env_stack_name}Staging.env"
    cp envs/template.env ${example_env1}
    sed -i -e "s|____default_aws_profile____|${default_aws_profile}|" ${example_env1}
    sed -i -e "s|____default_stack_type____|staging|" ${example_env1}
    sed -i -e "s|____default_base_stack_name____|${default_base_stack_name}Staging|" ${example_env1}
    sed -i -e "s|____default_env_stack_name____|${default_env_stack_name}Staging|" ${example_env1}

    example_env2="${target_dir}/envs/${default_base_stack_name}Prod-${default_env_stack_name}Prod.env"
    cp envs/template.env ${example_env2}
    sed -i -e "s|____default_aws_profile____|${default_aws_profile}|" ${example_env2}
    sed -i -e "s|____default_stack_type____|production|" ${example_env2}
    sed -i -e "s|____default_base_stack_name____|${default_base_stack_name}Prod|" ${example_env2}
    sed -i -e "s|____default_env_stack_name____|${default_env_stack_name}Prod|" ${example_env2}

    cp envs/readme.md ${target_dir}/envs/readme.md
    sed -i -e "s|____example_env1____|${example_env1}|" ${target_dir}/envs/readme.md
    sed -i -e "s|____example_env2____|${example_env2}|" ${target_dir}/envs/readme.md


setup_parameters target_dir=("install-test"):
    #!{{bash_shebang}}
    {{bash_options_for_just}}

    target_dir={{target_dir}}
    echo "Installing in: ${target_dir}"

    default_env_file="${target_dir}/envs/default.just"
    base_stack_name=$(grep '^default_base_stack_name' ${default_env_file} | sed -e 's/^default_base_stack_name[[:space:]]*:=[[:space:]]*"\(.*\)"$/\1/')
    env_stack_name=$(grep '^default_env_stack_name' ${default_env_file} | sed -e 's/^default_env_stack_name[[:space:]]*:=[[:space:]]*"\(.*\)"$/\1/')

    mkdir -p "${target_dir}/parameters/${base_stack_name}/${env_stack_name}"
    cp parameters/parameter-template.json "${target_dir}/parameters/${base_stack_name}/${base_stack_name}-base-stack-1.json"
    cp parameters/parameter-template.json "${target_dir}/parameters/${base_stack_name}/${env_stack_name}/${base_stack_name}-${env_stack_name}-stack-1.json"
    cp parameters/parameter-template.json "${target_dir}/parameters/${base_stack_name}/${env_stack_name}/${base_stack_name}-${env_stack_name}-stack-2.json"


setup_additional_parameters target_dir=("install-test"):
    #!{{bash_shebang}}
    {{bash_options_for_just}}

    target_dir={{target_dir}}
    echo "Installing in: ${target_dir}"

    read -rp "Setup additional sample parameter files? [y/N]: " confirm
    confirm=${confirm:-N}
    case "${confirm,,}" in
        y|yes)
          ;;
        *)
          echo "OK, skipping"
          exit 0
          ;;
    esac

    shopt -s nullglob

    for env_file in ${target_dir}/envs/*.env; do
        filename=$(basename "$env_file" .env)

        base_stack_name="${filename%%-*}"
        env_stack_name="${filename#*-}"

        mkdir -p "${target_dir}/parameters/${base_stack_name}/${env_stack_name}"
        cp parameters/parameter-template.json "${target_dir}/parameters/${base_stack_name}/${base_stack_name}-base-stack-1.json"
        cp parameters/parameter-template.json "${target_dir}/parameters/${base_stack_name}/${env_stack_name}/${base_stack_name}-${env_stack_name}-stack-1.json"
        cp parameters/parameter-template.json "${target_dir}/parameters/${base_stack_name}/${env_stack_name}/${base_stack_name}-${env_stack_name}-stack-2.json"
    done


copy_files target_dir=("install-test"):
    #!{{bash_shebang}}
    {{bash_options_for_just}}

    target_dir={{target_dir}}
    echo "Installing in: ${target_dir}"

    # setup directories
    mkdir -p ${target_dir}/justfiles
    mkdir -p ${target_dir}/envs
    mkdir -p ${target_dir}/parameters

    # copy template justfile
    cp justfile-template.just ${target_dir}/justfile

    # copy recipes
    cp justfiles/* ${target_dir}/justfiles/

check_installation target_dir=("install-test"):
    #!{{bash_shebang}}
    {{bash_options_for_just}}
    {{bash_noprint}}

    target_dir={{target_dir}}
    echo "Checking installation in: ${target_dir}"
    md5sum justfile-template ${target_dir}/justfile

    for f in $(find justfiles -maxdepth 1 -type f -printf '%f\n'); do
        echo "File ${f}"
        md5sum "justfiles/${f}" "${target_dir}/justfiles/${f}"
    done

uninstall target_dir=("install-test"):
    #!{{bash_shebang}}
    {{bash_options_for_just}}

    target_dir={{target_dir}}
    echo "Uninstalling from: ${target_dir}"

    rm -f "${target_dir}/justfile"

    for f in $(find justfiles -maxdepth 1 -type f -printf '%f\n'); do
        echo "File ${f}"
        rm -f "${target_dir}/justfiles/${f}"
    done
    [ -d "${target_dir}/justfiles" ] && rmdir "${target_dir}/justfiles"

    for f in $(find "${target_dir}/envs" -maxdepth 1 -type f -printf '%f\n'); do
        echo "File ${f}"
        rm -f "${target_dir}/envs/${f}"
    done
    [ -d "${target_dir}/envs" ] && rmdir "${target_dir}/envs"

    for f in $(find "${target_dir}/parameters" -type f); do
        echo "File ${f}"
        rm -f "${f}"
    done
    for d in $(find "${target_dir}/parameters" -type d | awk -F'/' '{print NF, $0}' | sort -rn | cut -d' ' -f2-); do
        echo "Directory ${d}"
        rmdir "${d}"
    done
    [ -d "${target_dir}/parameters" ] && rmdir "${target_dir}/parameters"

    rmdir ${target_dir}


a v="xxx": \
    (b v)\
    (c v)

b v="xxx":
    echo "bbbb: {{v}}"

c v="yyy":
    echo "ccc: {{v}}"
