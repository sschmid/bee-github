#!/usr/bin/env bash

github::_new() {
  echo "# github => $(github::_deps)"
  echo 'GITHUB_ORG="org"
GITHUB_ORG_ID="0123456789"
GITHUB_REPO="${GITHUB_ORG}/${BEE_PROJECT}"
GITHUB_CHANGES=CHANGES.md
GITHUB_RELEASE_PREFIX="${BEE_PROJECT}-"
GITHUB_ASSETS_ZIP=("Build/${BEE_PROJECT}.zip")
# Potentially sensitive data. Do not commit.
GITHUB_ACCESS_TOKEN="0123456789"'
}

github::_deps() {
  echo "version"
}

github::me() {
  curl -s -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
    "https://api.github.com/user"
}

github::org() {
  local name="${1}"
  curl -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
    "https://api.github.com/orgs/${name}"
}

github::create_org_repo() {
  local name="$1"
  local private="$2"
  curl -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
    -d "{\"name\": \"${name}\", \"private\": ${private}}" \
    "https://api.github.com/orgs/${GITHUB_ORG}/repos"
}

github::create_release() {
  local version changes data
  version="$(version::read)"
  changes="$(cat "${GITHUB_CHANGES}")"
  changes="${changes//$'\n'/\\n}"
  data=$(cat <<EOF
{
  "tag_name": "${version}",
  "name": "${GITHUB_RELEASE_PREFIX}${version}",
  "body": "${changes}"
}
EOF
)
  curl -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
    -d "${data}" \
    "https://api.github.com/repos/${GITHUB_REPO}/releases"
}

github::upload_assets() {
  if [[ ${#GITHUB_ASSETS_ZIP[@]} -gt 0 ]]; then
    local id="$1"
    local upload_url="https://uploads.github.com/repos/${GITHUB_REPO}/releases/${id}/assets"
    for f in "${GITHUB_ASSETS_ZIP[@]}"; do
      {
        curl -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
          -H "Content-Type:application/zip" \
          --data-binary "@${f}" \
          "${upload_url}"?name="$(basename "${f}")"

        echo
       } &
    done
    wait
  fi
}

github::repos() {
  local org="${1:-$GITHUB_ORG}"
  curl -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/${org}/repos"
}

github::teams() {
  curl -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
    "https://api.github.com/repos/${GITHUB_REPO}/teams"
}

github::add_team() {
  local id="$1"
  local permission="$2"
  local data="{\"permission\": \"${permission}\"}"
  curl -X PUT \
    -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
    -d "${data}" \
    "https://api.github.com/organizations/${GITHUB_ORG_ID}/team/${id}/repos/${GITHUB_REPO}"
}

github::remove_team() {
  local id="$1"
  curl -X DELETE \
    -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
    "https://api.github.com/organizations/${GITHUB_ORG_ID}/team/${id}/repos/${GITHUB_REPO}"
}

github::add_user() {
  local user_name="$1"
  local permission="$2"
  local data="{\"permission\": \"${permission}\"}"
  curl -X PUT \
    -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
    -d "${data}" \
    "https://api.github.com/repos/${GITHUB_REPO}/collaborators/${user_name}"
}

github::remove_user() {
  local user_name="$1"
  curl -X DELETE \
    -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
    "https://api.github.com/repos/${GITHUB_REPO}/collaborators/${user_name}"
}

github::set_topics() {
  local -a topics=("$@")
  topics=("${topics[@]/#/\"}")
  topics=("${topics[@]/%/\"}")
  local data="{\"names\":[$(join_by "," "${topics[@]}")]}"
  curl -X PUT \
    -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
    -H "Accept: application/vnd.github.mercy-preview+json" \
    -d "${data}" \
    "https://api.github.com/repos/${GITHUB_REPO}/topics"
}

join_by() {
  local IFS="$1"
  shift
  echo "$*"
}

github::get_branch_protection() {
  local branch="$1"
  curl \
    -u "${GITHUB_ORG}:$GITHUB_ACCESS_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${GITHUB_REPO}/branches/${branch}/protection"
}

github::update_branch_protection() {
  local branch="$1"
  local data="$2"
  curl \
    -X PUT \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Accept: application/vnd.github.luke-cage-preview+json" \
    -u "${GITHUB_ORG}:$GITHUB_ACCESS_TOKEN" \
    -d "${data}" \
    "https://api.github.com/repos/${GITHUB_REPO}/branches/${branch}/protection"
}
