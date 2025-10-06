# just-aws

A collection of just recipes to automate and simplify interactions with AWS CLI, the focus is on infrastructure as code
and CloudFormation stack management.

The recipes assume an opinionated structure for both the environment and the structure of the stacks.

## Environments (infrastructures)

Environment, used a synonym of infrastructure, is a collection of AWS entities serving a particular purpose.
In general, the infrastructure can be deployed in different AWS Accounts and can be used for different stages like
development or production.

An environment is deployed using several stacks to maintain modularity and allow single stacks to be reused in
different projects.

Additionally, in some use cases, typically to optimize costs, it is assumed that different environments may share some
resources; a classic example is two different development environments that share the same Internet Gateway or NAT
Gateway (as a consequence they also need to share the same VPC and public subnet), this approach goes against the
separation of environments but allows sharing some (potentially expensive entities) hence saving some costs.
The above is modeled using the concept of "base" environment: a base environment is a collection of stacks that are
shared by all "children" environments.

Environments are thus defined by four variables:

* _aws_profile_: the AWS profile to use, as defined in .aws/config, this allows using different AWS accounts for
  different
  environments
* _stack_type_: possible types are: development / staging / production, different stack types have different
  configuration files, and a stack type also selects values in Parameter Store and Secrets Manager
* _base_stack_name_: the name of the base env; the base env is where resources that can be shared like the VPC, public
  subnets, Internet and NAT gateways, EC2 instance connect and Image Builder pipelines are defined. It is possible to
  have one base stack per multiple envs, for example, a "DevAndStaging" base env that hosts all dev and staging envs
  and a "LiveProduction" base env that hosts the production env. Note that a base env can have just a single env as a
  child when separation makes more sense than cost optimization
* _env_stack_name_: the name of the env, one env belongs to an AWS profile (i.e., AWS Account), has a type
  (development / staging / production), belongs to a base env and is composed by several stacks

In practice the distinction between base and env stacks is relevant for the naming convention of the exported parameters
used by inter-dependent stacks.

# Usage

The recipes defined here have the purpose of automating and simplifying interactions with AWS CLI, each recipe can be
thought as a simple command can be used and reused in a different project and for different infrastructure.

To allow this simplicity, the recipes assume a structure of projects, environments and some naming convention.

For each project there will be a "master" justfile that will call the recipes to manage the infrastructure: deploy and
undeploy the resources, clean up, etc. There are also utilities infer parameters of some entities, like dynamic
IPs, queue and bucket names, etc.
The notion of environments (envs), the naming conventions for parameter files and the use of some variables allow to use
a single justfile for multiple environments of different types.

To use the collection, you need to:

* define the environment you need to have and set up the relevant files
* create the master justfile: this depends on the structure and the entities of your infrastructure
* write the CloudFormation templates and the relevant parameter names 