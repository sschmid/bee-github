#!/usr/bin/env bash

github::_new() {
  echo "# github => $(github::_deps)"
  echo 'GITHUB_ORG="org"
GITHUB_ORG_ID="0123456789"
GITHUB_REPO="${GITHUB_ORG}/${BEE_PROJECT}"
GITHUB_CHANGES=CHANGES.md
GITHUB_RELEASE_PREFIX="${BEE_PROJECT}-"
GITHUB_ASSETS_ZIP=("Build/${BEE_PROJECT}.zip")
# secrets:
# github.token'
}

github::_deps() {
  echo "version"
}

github::me() {
  local token
  token="$(bee::secrets github.token)"
  curl -s -H "Authorization: token ${token}" \
    "https://api.github.com/user"
}

github::org() {
  local name="${1}" token
  token="$(bee::secrets github.token)"
  curl -H "Authorization: token ${token}" \
    "https://api.github.com/orgs/${name}"
}

github::create_org_repo() {
  local name="$1" private="$2" token
  token="$(bee::secrets github.token)"
  curl -H "Authorization: token ${token}" \
    -d "{\"name\": \"${name}\", \"private\": ${private}}" \
    "https://api.github.com/orgs/${GITHUB_ORG}/repos"
}

github::create_release() {
  local version changes data token
  token="$(bee::secrets github.token)"
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
  curl -H "Authorization: token ${token}" \
    -d "${data}" \
    "https://api.github.com/repos/${GITHUB_REPO}/releases"
}

github::upload_assets() {
  if [[ ${#GITHUB_ASSETS_ZIP[@]} -gt 0 ]]; then
    local id="$1" upload_url="https://uploads.github.com/repos/${GITHUB_REPO}/releases/${id}/assets" token
    token="$(bee::secrets github.token)"
    for f in "${GITHUB_ASSETS_ZIP[@]}"; do
      {
        curl -H "Authorization: token ${token}" \
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
  local org="${1:-$GITHUB_ORG}" token
  token="$(bee::secrets github.token)"
  curl -H "Authorization: token ${token}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/${org}/repos"
}

github::teams() {
  local token
  token="$(bee::secrets github.token)"
  curl -H "Authorization: token ${token}" \
    "https://api.github.com/repos/${GITHUB_REPO}/teams"
}

github::add_team() {
  local id="$1" permission="$2" data="{\"permission\": \"${permission}\"}" token
  token="$(bee::secrets github.token)"
  curl -X PUT \
    -H "Authorization: token ${token}" \
    -d "${data}" \
    "https://api.github.com/organizations/${GITHUB_ORG_ID}/team/${id}/repos/${GITHUB_REPO}"
}

github::remove_team() {
  local id="$1" token
  token="$(bee::secrets github.token)"
  curl -X DELETE \
    -H "Authorization: token ${token}" \
    "https://api.github.com/organizations/${GITHUB_ORG_ID}/team/${id}/repos/${GITHUB_REPO}"
}

github::add_user() {
  local user_name="$1" permission="$2" data="{\"permission\": \"${permission}\"}" token
  token="$(bee::secrets github.token)"
  curl -X PUT \
    -H "Authorization: token ${token}" \
    -d "${data}" \
    "https://api.github.com/repos/${GITHUB_REPO}/collaborators/${user_name}"
}

github::remove_user() {
  local user_name="$1" token
  token="$(bee::secrets github.token)"
  curl -X DELETE \
    -H "Authorization: token ${token}" \
    "https://api.github.com/repos/${GITHUB_REPO}/collaborators/${user_name}"
}

github::set_topics() {
  local -a topics=("$@") data token
  topics=("${topics[@]/#/\"}")
  topics=("${topics[@]/%/\"}")
  data="{\"names\":[$(join_by "," "${topics[@]}")]}"
  token="$(bee::secrets github.token)"
  curl -X PUT \
    -H "Authorization: token ${token}" \
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
  local branch="$1" token
  token="$(bee::secrets github.token)"
  curl \
    -u "${GITHUB_ORG}:${token}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${GITHUB_REPO}/branches/${branch}/protection"
}

github::update_branch_protection() {
  local branch="$1" data="$2" token
  token="$(bee::secrets github.token)"
  curl \
    -X PUT \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Accept: application/vnd.github.luke-cage-preview+json" \
    -u "${GITHUB_ORG}:${token}" \
    -d "${data}" \
    "https://api.github.com/repos/${GITHUB_REPO}/branches/${branch}/protection"
}
