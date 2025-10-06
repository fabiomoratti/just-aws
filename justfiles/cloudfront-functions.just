# ----------------------------------------------------------------------------------------------------------------------
# Documentation to be written
# ----------------------------------------------------------------------------------------------------------------------

[group('CloudFront')]
[doc('Shortcut for listing CloudFront distributions')]
lsdis: list_distributions


[group('CloudFront')]
[doc('Lists CloudFront distributions')]
list_distributions: _list_distributions


[group('CloudFront')]
[doc('Shortcut for invalidating a distribution - i.e. clear the cache - given the distribution id')]
ic _distribution_id: (invalidate_cache _distribution_id)


[group('CloudFront')]
[doc('Invalidate a distribution - i.e. clear the cache - given the distribution id')]
invalidate_cache _distribution_id: (_create_invalidation _distribution_id)


_list_distributions:
    #!{{bash_shebang}}
    echo "========================= List CloudFront distributions ========================="
    aws cloudfront \
      --no-cli-pager \
      list-distributions \
      --query "DistributionList.Items[].[Id,Comment]"
    echo "--------------------------------------------------------------------------------"


_create_invalidation _distribution_id:
    #!{{bash_shebang}}
    echo "=============================== Invalidate cache ==============================="
    echo "distribution_id: {{_distribution_id}}"
    echo "--------------------------------------------------------------------------------"
    distribution_domain=$(aws cloudfront \
                          list-distributions \
                          --no-cli-pager \
                          --query "DistributionList.Items[?Id=='{{_distribution_id}}'].[Comment][]|[0]" |
                          sed -e 's/"//g')
    echo "Invalidating distribution ${distribution_domain}"

    aws cloudfront \
      --no-cli-pager \
      create-invalidation \
      --distribution-id {{_distribution_id}} \
      --paths "/*"
