# Default region
default_region := "____default_region____"

# The name of the bucket used to store the templates on S3, where the bucket is created influences the bucket endpoint
stack_bucket := "____stack_bucket____"

# The endpoint URL of the bucket that contains the stack templates, depends on the bucket and is set at its creation
stack_bucket_endpoint := "____stack_bucket_endpoint____"

# Cloudfront Certificate Region - N. Virginia - AWS requirement, cannot be changed
cloudfront_certificate_region := "us-east-1"

# Cognito Certificate Region - N. Virginia - AWS requirement, cannot be changed
auth_certificate_region := "us-east-1"

# Application user provisioned on EC2 instances, used to connect
os_user := "____os_user____"

# TODO - investigate if there is a better way to create the token
# Just a random string
stack_token_post_fix := "token-1"

# The folder where the parameters file are stored
parameters_dir := "parameters"

# Stack status check frequency
status_check_sleep_time := "5"
