#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_dir=$(readlink -f $script_dir/..)
if [ -f $project_dir/.env ]; then
  source $project_dir/.env;
fi

GITHUB_OWNER=$(basename $(dirname `git rev-parse --show-toplevel`))
GITHUB_REPO=$(basename $(git remote get-url origin) .git)

ISF='' read -r -d '' query <<-END_GQL
query {
  repository(owner: "$GITHUB_OWNER", name: "$GITHUB_REPO") {
    pullRequests(first:100, states:[OPEN], orderBy:{field: UPDATED_AT, direction:DESC}) {
      pageInfo {
        hasNextPage
        endCursor
      }
      edges {
        node {
          headRefName
        }
      }
    }
  }
}
END_GQL

query_json=$(jq -n --arg query "$query" '{"query": $query}')
branches_json=$(curl --silent -H "Authorization: bearer $GITHUB_KEY" -X POST -d "$query_json" https://api.github.com/graphql)

jq --raw-output '.data.repository.pullRequests.edges | .[] | .node.headRefName' <<< $branches_json

while [ $(jq --raw-output '.data.repository.pullRequests.pageInfo.hasNextPage' <<< $branches_json) = "true" ]; do
  cursor=$(jq --raw-output '.data.repository.pullRequests.pageInfo.endCursor' <<< $branches_json)
  ISF='' read -r -d '' query <<-END_GQL
  query {
    repository(owner: "$GITHUB_OWNER", name: "$GITHUB_REPO") {
      pullRequests(first:100, states:[OPEN], orderBy:{field: UPDATED_AT, direction:DESC} after:"$cursor") {
        pageInfo {
          hasNextPage
          endCursor
        }
        edges {
          node {
            headRefName
          }
        }
      }
    }
  }
END_GQL

  query_json=$(jq -n --arg query "$query" '{"query": $query}')
  branches_json=$(curl --silent -H "Authorization: bearer $GITHUB_KEY" -X POST -d "$query_json" https://api.github.com/graphql)

  jq --raw-output '.data.repository.pullRequests.edges | .[] | .node.headRefName' <<< $branches_json
done
