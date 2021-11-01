

function listTags() {
    local repo=${1}
    local size=${2:-25}
    local page=${3:-1}
    [ -z "${repo}" ] && echo "Usage: listTags <repoName> [size] [pageIndex]" 1>&2 && return 1
    curl "https://registry.hub.docker.com/api/content/v1/repositories/public/library/${repo}/tags?page=${page}&page_size=${size}" 2>/dev/null | jq -r '.results[].name' | sort
}
