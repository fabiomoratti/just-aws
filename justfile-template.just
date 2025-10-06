# -----------------------------------------------------------------------------
# Just reference documentation
# -----------------------------------------------------------------------------
# https://github.com/casey/just
# https://just.systems/man/en/chapter_1.html
# https://cheatography.com/linux-china/cheat-sheets/justfile/
# -----------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# This not technically needed, on Windows could be a workaround for this issue:
# https://github.com/casey/just/issues/2143
# Once the configuration quirk is resolved, can be removed
export JUST_DUMMY_VARIABLE := "JUST_DUMMY_VALUE"
# ----------------------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------------------------
# Setup Environment
# ----------------------------------------------------------------------------------------------------------------------

# Environments are defined by four variables:
#  - aws_profile: the AWS profile to use, as defined in .aws/config
#  - stack_type: possible types are: development / staging / production, stack type selects values in Parameter Store
#                and Secrets Manager
#
#  - base_stack_name: the name of the base env; the base env is where the VPC, public subnets, Internet and NAT
#                     gateways, EC2 instance connect and Image Builder pipelines are defined. There is one base stack
#                     per multiple envs, usually "DevAndStaging" that hosts all dev and staging env and "LiveProduction"
#
# - env_stack_name: the name of the env, one env belongs to an AWS profile (i.e. account), has a type (develompent /
#                   staging / production), belongs to a base env and is composed by several stacks

# Loads the default environment, used when the the JUST_ENV variable is not set
# The env variables depend on the project
import 'envs/default.just'

# Loads the common variables for the project; note that common variables in general do not change for different
# environments but may change for different AWS accounts, so typically JUST_COMMON can be unset and the default
# common.just file is imported, for special needs use JUST_COMMON to point to the correct "common" file.
# Common files should have the name "common-<special-common-settings>"
import x'envs/${JUST_COMMON:-common}.just'

# Load common and test recipes
import '../justfiles/functions.just'
import '../justfiles/test-functions.just'

# Dot-env files in the 'envs' folder contain four environment variables (corresponding to the Just variables that
# define the env), the dot-env file and the environment variables serves two scopes:
#  - the dot-env filename can be loaded using shell expansion (see https://just.systems/man/en/chapter_30.html, last
#    paragraph, at the time of writing), will load the file defined in the JUST_ENV environment variable, if JUST_ENV
#    is not defined it will fallback to a non existent file
#  - if the dot-env file does not exist or doesn't contain the expected variables the env falls back to the default
#    defined above
set dotenv-filename := x'envs/${JUST_ENV:-dummy}.env'

# Configure the env, from the environemnt variables or falling back to the default loaded from 'envs/default.just'
aws_profile := env_var_or_default('JUST_ENV_AWS_PROFILE', default_aws_profile)
stack_type := env_var_or_default('JUST_ENV_STACK_TYPE', default_stack_type)
base_stack_name := env_var_or_default('JUST_ENV_BASE_STACK_NAME', default_base_stack_name)
env_stack_name := env_var_or_default('JUST_ENV_ENV_STACK_NAME', default_env_stack_name)

# The main stack name is computed from base and env
main_stack_name := base_stack_name + "-" + env_stack_name

# This is needed to override the AWS profile eventually defined in the current shell, remember that variables
# exported in here are passed to each shell spawned by Just tasks
export AWS_PROFILE := aws_profile

# ----------------------------------------------------------------------------------------------------------------------
# Recipes
# ----------------------------------------------------------------------------------------------------------------------

default:
    aws --version
    aws configure list
    sam.cmd --version
    just --list
    just print_environment_variables
    just print_current_env


# --------------------
# Project recipes
# --------------------
# This is a good place to define project related recipes that do not (or partially) use general purpose recipes defined
# in the functions

# ----------------------
# "All" recipes for base
# ----------------------

# This is the suggested place to define the recipes used to manage the "base" components of the stack e.g. VPC,
# network, nat, etc.
# The workflow is delete -> copy (in the bucket) -> validate -> create

# The following are some example recipes for base components stacks like network and nat gw, you mileage may vary

# deploy_base_all: delete_base_all copy_base_all validate_base_all create_base_network create_base_nat_gateway
# delete_base_all: delete_base_nat_gateway  delete_base_network
# copy_base_all: copy_base_network copy_base_nat_gateway
# validate_base_all: validate_base_network validate_base_nat_gateway
# deploy_base_network: delete_base_network copy_base_network validate_base_network create_base_network
# deploy_base_nat_gateway: delete_base_nat_gateway copy_base_nat_gateway validate_base_nat_gateway create_base_nat_gateway


# ----------------------
# "All" recipes for envs
# ----------------------

# Same as above but for envs components

# deploy_all: delete_all copy_all validate_all create_stack_network create_sg
# delete_all: delete_sg delete_stack_network
# copy_all: copy_stack_network copy_sg
# validate_all: validate_stack_network validate_sg
# deploy_stack_network: delete_stack_network copy_stack_network validate_stack_network create_stack_network
# deploy_sg: delete_sg copy_sg validate_sg create_sg

# ------------------------------------------------
# Copy, validate, delete, create for single stacks
# ------------------------------------------------

# Single aliases example for base and env stacks

# Examples for base and env stacks (network only)
# copy_base_network: (_copy_base_template "base-network")
# validate_base_network: (_validate_base_template "base-network")
# delete_base_network: (_delete_base_stack "base-network") (_delete_base_stack_wait "base-network")
# create_base_network: (_create_base_stack "base-network") (_create_base_stack_wait "base-network")

# create_nowait_base_network: (_create_base_stack "base-network")
# delete_nowait_base_network: (_delete_base_stack "base-network")


# copy_stack_network: (_copy_template "stack-network")
# validate_stack_network: (_validate_template "stack-network")
# delete_stack_network: (_delete_stack "stack-network") (_delete_stack_wait "stack-network")
# create_stack_network: (_create_stack "stack-network") (_create_stack_wait "stack-network")

# create_nowait_stack_network: (_create_stack "stack-network")
# delete_nowait_stack_network: (_delete_stack "stack-network")
