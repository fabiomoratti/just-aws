
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
# ----------------------------------------------------------------------------------------------------------------------
export JUST_DUMMY_VARIABLE := "JUST_DUMMY_VALUE"
bash_shebang := if os() == 'windows' {
	'/bin/bash'
} else {
	'/bin/bash'
}

import 'env-functions.just'
import 'stack-functions.just'
import 'changeset-functions.just'
import 'ec2-functions.just'
import 'imagebuilder-functions.just'
import 'cloudfront-functions.just'
import 'cloudmap-functions.just'
import 'cognito-functions.just'
import 's3-functions.just'
import 'ssm-functions.just'

# TODO - remove certificate arn from (input) parameters for stacks that read the SSM parameter

# For some use cases the certificate for a resource must be created in the North Virginia (us-east-1) regionl; this
# means that even if the stack that provisions the certificate exports the certificate ARN as an output, a different
# stack that depends on this ARN but is deployed in another regon not cannot import it.
# This recipe, to be called and the end of the certificate-creation stack provisioning, reads the the Certificate and
# HostName parameters stack outputs and saves the ARN to a SSM parameter with the name:
#       /certificate/<_component>/<host_name>
# Note that the recipe assumes that the certificate provisioning stack:
# - is deployed in us-east-1
# - exports a parameter called "Certificate"
# - exports a parameter called "HostName"
# Possible enhancements:
# - examine the certificate instead of the outputs
# - move Certificate and HostName into variables
# - move region into variable
_save_certificate_arn _component:
    #!{{bash_shebang}}
    echo "============================= Save certificate ARN ============================="
    echo "stack_name: {{main_stack_name}}-{{_component}}"
    echo "region: us-east-1"
    echo "certificate parameter name: Certificate"
    echo "host name paramenter name: HostName"
    echo "--------------------------------------------------------------------------------"

    certificate_arn=$(aws cloudformation \
      --no-cli-pager \
      describe-stacks \
      --region us-east-1 \
      --stack-name {{main_stack_name}}-{{_component}} \
      --query "Stacks[0].Outputs[?OutputKey=='Certificate'].OutputValue|[0]" |
      sed -e 's/"//g')
    echo "certificate_arn: ${certificate_arn}"

    host_name=$(aws cloudformation \
        --no-cli-pager \
        describe-stacks \
        --region us-east-1 \
        --stack-name {{main_stack_name}}-{{_component}} \
        --query "Stacks[0].Outputs[?OutputKey=='HostName'].OutputValue|[0]" |
        sed -e 's/"//g')
    echo "host_name: ${host_name}"

    echo "parameter_name: /certificate/{{_component}}/${host_name}"
    aws ssm \
        --no-cli-pager \
        put-parameter \
        --name " /certificate/{{_component}}/${host_name}" \
        --value "${certificate_arn}" \
        --type String \
        --overwrite
