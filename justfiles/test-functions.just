# ----------------------------------------------------------------------------------------------------------------------
# No automated tests yet.
# Just some recipes to double-check functionalities
# ----------------------------------------------------------------------------------------------------------------------


_test_bash_options_for_just:
    #!{{bash_shebang}}
    {{bash_options_for_just}}
    set -o

_test_fill_buckets: \
    (_test_fill_bucket "frontend-cloudfront" "LoggingBucketName") \
    (_test_fill_bucket "frontend-cloudfront" "SiteBucketName") \
    (_test_fill_bucket "release-bucket" "ReleaseBucketName")

_test_fill_file _file_path:
    #!{{bash_shebang}}
    cat > {{_file_path}} << __EOF__
    Some random content
    Some more random content
    Yet another random content
    Random content galore!!!
    __EOF__

_test_create_temp_folders:
    #!{{bash_shebang}}
    mkdir test_bucket_files_to_be_removed
    mkdir test_bucket_files_to_be_removed/folder_1
    mkdir test_bucket_files_to_be_removed/folder_1/folder_1_1
    mkdir test_bucket_files_to_be_removed/folder_1/folder_1_2
    mkdir test_bucket_files_to_be_removed/folder_2
    mkdir test_bucket_files_to_be_removed/folder_2/folder_2_1
    mkdir test_bucket_files_to_be_removed/folder_2/folder_2_2
    mkdir test_bucket_files_to_be_removed/folder_3
    mkdir test_bucket_files_to_be_removed/folder_3/folder_3_1
    mkdir test_bucket_files_to_be_removed/folder_3/folder_3_2
    mkdir test_bucket_files_to_be_removed/folder_3/folder_3_3

_test_create_fake_contents: \
    _test_create_temp_folders \
    (_test_fill_file "test_bucket_files_to_be_removed/file1") \
    (_test_fill_file "test_bucket_files_to_be_removed/folder_1/file2") \
    (_test_fill_file "test_bucket_files_to_be_removed/folder_1/folder_1_1/file3") \
    (_test_fill_file "test_bucket_files_to_be_removed/folder_1/folder_1_1/file4") \
    (_test_fill_file "test_bucket_files_to_be_removed/folder_1/folder_1_2/file5") \
    (_test_fill_file "test_bucket_files_to_be_removed/folder_2/file6") \
    (_test_fill_file "test_bucket_files_to_be_removed/folder_2/folder_2_1/file7") \
    (_test_fill_file "test_bucket_files_to_be_removed/folder_2/folder_2_2/file8") \
    (_test_fill_file "test_bucket_files_to_be_removed/folder_3//file9") \
    (_test_fill_file "test_bucket_files_to_be_removed/folder_3/folder_3_1/file10") \
    (_test_fill_file "test_bucket_files_to_be_removed/folder_3/folder_3_2/file11") \
    (_test_fill_file "test_bucket_files_to_be_removed/folder_3/folder_3_3/file12") \

_test_clean_fake_contents:
    #!{{bash_shebang}}
    rm -rf test_bucket_files_to_be_removed

_test_fill_bucket _component _bucket_name:
    #!{{bash_shebang}}
    echo "=== Empty bucket - {{_component}} {{_bucket_name}} ==="
    echo "stack_name: {{main_stack_name}}"
    echo "component: {{_component}}"
    echo "bucket_key: {{_bucket_name}}"

    bucket_name=$(aws cloudformation \
    describe-stacks \
    --no-cli-pager \
    --stack-name {{main_stack_name}}-{{_component}} \
    --query "Stacks[0].\
    Outputs[?OutputKey=='{{_bucket_name}}'].\
    OutputValue|[0]" |
    sed -e 's/"//g')
    echo "bucket name: ${bucket_name}"

    aws s3 cp test_bucket_files_to_be_removed/ s3://${bucket_name}/ --recursive

test_user_specific_functions:
     @echo "The user-specific cache directory: {{cache_directory()}}"
     @echo "The user-specific configuration directory: {{config_directory()}}"
     @echo "The local user-specific configuration directory: {{config_local_directory()}}"
     @echo "The user-specific data directory: {{data_directory()}}"
     @echo "The local user-specific data directory: {{data_local_directory()}}"
     @echo "The user’s home directory: {{home_directory()}}"
