# ----------------------------------------------------------------------------------------------------------------------
# Documentation to be written
# ----------------------------------------------------------------------------------------------------------------------

# TODO - fix hardcoded APIUserPool
_list_user_pool_clients:
    #!{{bash_shebang}}
    echo "================== Listing user pool clients for Cognito Pool =================="
    echo "Cognito Pool Name: {{main_stack_name}}-APIUserPool"
    echo "--------------------------------------------------------------------------------"

    user_pool_id=$(aws cognito-idp \
      --no-cli-pager \
      list-user-pools \
      --max-results 60 \
      --query "UserPools[?Name=='{{main_stack_name}}-APIUserPool'].Id|[0]" |
      sed -e 's/"//g')
    echo "User pool id for {{main_stack_name}}-APIUserPool: ${user_pool_id}"

    user_pool_clients_id_list=($(aws cognito-idp \
      --no-cli-pager \
      list-user-pool-clients \
      --user-pool-id ${user_pool_id} \
      --query "UserPoolClients[].ClientId" |
      sed -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/,/ /g'))

    echo "============================ User Pool Clients List ============================"
    for user_pool_client_id in ${user_pool_clients_id_list[@]}; do
      aws cognito-idp \
        --no-cli-pager \
        describe-user-pool-client \
        --user-pool-id ${user_pool_id} \
        --client-id ${user_pool_client_id} \
        --query "UserPoolClient.{ClientId:ClientId,ClientName:ClientName,ClientSecret:ClientSecret}"
    done
    echo "--------------------------------------------------------------------------------"

# TODO - fix hardcoded APIUserPool
# TODO - scopes
_add_app_client _client_name:
    #!{{bash_shebang}}
    echo "============================= Add user pool client ============================="
    echo "Cognito Pool Name: {{main_stack_name}}-APIUserPool"
    echo "Client name: {{_client_name}}"
    echo "--------------------------------------------------------------------------------"

    user_pool_id=$(aws cognito-idp \
      --no-cli-pager \
      list-user-pools \
      --max-results 60 \
      --query "UserPools[?Name=='{{main_stack_name}}-APIUserPool'].Id|[0]" |
      sed -e 's/"//g')
    echo "User pool id for {{main_stack_name}}-APIUserPool: ${user_pool_id}"

    client_name={{main_stack_name}}-{{_client_name}}
    echo "Client Name: ${client_name}"

    aws cognito-idp \
      --no-cli-pager \
      create-user-pool-client \
      --user-pool-id ${user_pool_id} \
      --client-name ${client_name} \
      --allowed-o-auth-scopes {{main_stack_name}}/test_scope \
      --allowed-o-auth-flows client_credentials \
      --allowed-o-auth-flows-user-pool-client \
      --enable-token-revocation \
      --generate-secret \
      --supported-identity-providers COGNITO \
      --access-token-validity "60" \
      --id-token-validity "60" \
      --refresh-token-validity "30" \
      --token-validity-units AccessToken="minutes",IdToken="minutes",RefreshToken="days"

    client_id=$(aws cognito-idp \
    list-user-pool-clients \
    --no-cli-pager \
    --user-pool-id ${user_pool_id} \
    --query "UserPoolClients[?ClientName=='${client_name}'].ClientId|[0]" |
    sed -e 's/"//g')
    echo "client_id: ${client_id}"

    api_id=$(aws apigatewayv2 \
    get-apis \
    --no-cli-pager \
    --query "Items[?Name=='thirdparty-{{main_stack_name}}'].ApiId|[0]" |
    sed -e 's/"//g')
    echo "api_id: ${api_id}"

    authorizer_id=$(aws apigatewayv2 \
    get-authorizers \
    --no-cli-pager \
    --api-id ${api_id} \
    --query "Items[?Name=='cognito-jwt-{{main_stack_name}}'].AuthorizerId|[0]" |
    sed -e 's/"//g')
    echo "authorizer_id: ${authorizer_id}"

    current_clients_id=$(aws apigatewayv2 \
    get-authorizer \
    --no-cli-pager \
    --api-id ${api_id} \
    --authorizer-id ${authorizer_id} \
    --query "JwtConfiguration.Audience" |
    sed -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/[[:space:]]//g' |
    tr -d '\n')
    echo "current_clients_id: ${current_clients_id}"

    aws apigatewayv2 \
    update-authorizer \
    --no-cli-pager \
    --api-id ${api_id} \
    --authorizer-id ${authorizer_id} \
    --jwt-configuration Audience=${current_clients_id},${client_id}

# TODO - fix hardcoded APIUserPool
_delete_app_client _client_name:
    #!{{bash_shebang}}
    echo "============================ Remove user pool client ==========================="
    echo "Cognito Pool Name: {{main_stack_name}}-APIUserPool"
    echo "_client_name: {{_client_name}}"
    echo "--------------------------------------------------------------------------------"

    user_pool_id=$(aws cognito-idp \
      --no-cli-pager \
      list-user-pools \
      --max-results 60 \
      --query "UserPools[?Name=='{{main_stack_name}}-APIUserPool'].Id|[0]" | \
      sed -e 's/"//g')
    echo "User pool id for {{main_stack_name}}-APIUserPool: ${user_pool_id}"

    client_name="{{main_stack_name}}-{{_client_name}}"
    echo "client_name: ${client_name}"

    client_id=$(aws cognito-idp \
        list-user-pool-clients \
        --no-cli-pager \
        --user-pool-id ${user_pool_id} \
        --query "UserPoolClients[?ClientName=='${client_name}'].ClientId|[0]" |
        sed -e 's/"//g')
    echo "client_id: ${client_id}"

    aws cognito-idp \
        --no-cli-pager \
        delete-user-pool-client \
        --user-pool-id ${user_pool_id} \
        --client-id ${client_id}

    api_id=$(aws apigatewayv2 \
        get-apis \
        --no-cli-pager \
        --query "Items[?Name=='thirdparty-{{main_stack_name}}'].ApiId|[0]" |
        sed -e 's/"//g')
    echo "api_id: ${api_id}"

    authorizer_id=$(aws apigatewayv2 \
    get-authorizers \
    --no-cli-pager \
    --api-id ${api_id} \
    --query "Items[?Name=='cognito-jwt-{{main_stack_name}}'].AuthorizerId|[0]" |
    sed -e 's/"//g')
    echo "authorizer_id: ${authorizer_id}"

    current_clients_id=$(aws apigatewayv2 \
    get-authorizer \
    --no-cli-pager \
    --api-id ${api_id} \
    --authorizer-id ${authorizer_id} \
    --query "JwtConfiguration.Audience" |
    sed -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/[[:space:]]//g' |
    tr -d '\n')
    echo "current_clients_id: ${current_clients_id}"

    updated_clients_id=$(echo ${current_clients_id//${client_id}/} | sed -e 's/,,/,/g' -e 's/^,//g' -e 's/,$//g')
    echo "updated_clients_id: ${updated_clients_id}"

    aws apigatewayv2 \
    update-authorizer \
    --no-cli-pager \
    --api-id ${api_id} \
    --authorizer-id ${authorizer_id} \
    --jwt-configuration Audience=${updated_clients_id}


# TODO - check if TestClient need to stay
_delete_all_user_pool_clients:
    #!{{bash_shebang}}
    echo "========================== Remove ALL user pool clients ========================="
    echo "Cognito Pool Name: {{main_stack_name}}-APIUserPool"
    echo "--------------------------------------------------------------------------------"

    user_pool_id=$(aws cognito-idp \
      --no-cli-pager \
      list-user-pools \
      --max-results 60 \
      --query "UserPools[?Name=='{{main_stack_name}}-APIUserPool'].Id|[0]" |
      sed -e 's/"//g')
    echo "User pool id for {{main_stack_name}}-APIUserPool: ${user_pool_id}"

    user_pool_clients_id_list=($(aws cognito-idp \
      --no-cli-pager \
      list-user-pool-clients \
      --user-pool-id ${user_pool_id} \
      --query "UserPoolClients[].ClientId" | \
      sed -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/,/ /g'))

    for user_pool_client_id in ${user_pool_clients_id_list[@]}; do
        echo "Deleting ${user_pool_client_id} from ${user_pool_id}"
        aws cognito-idp \
        delete-user-pool-client \
        --no-cli-pager \
        --user-pool-id ${user_pool_id} \
        --client-id ${user_pool_client_id}
    done
