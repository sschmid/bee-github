: "${BEE_PROJECT:="Project"}"
: "${GITHUB_CHANGES:=CHANGES.md}"
: "${GITHUB_RELEASE_PREFIX:="${BEE_PROJECT}-"}"

if [[ ! -v GITHUB_ASSETS_ZIP ]]; then GITHUB_ASSETS_ZIP=(); fi

github::help() {
  cat << 'EOF'
template:

  GITHUB_ORG="org"
  GITHUB_ORG_ID="0123456789"
  GITHUB_REPO="${GITHUB_ORG}/${BEE_PROJECT}"
  GITHUB_CHANGES=CHANGES.md # default
  GITHUB_RELEASE_PREFIX="${BEE_PROJECT}-" # default
  GITHUB_ASSETS_ZIP=() # default

secrets:

  GITHUB_TOKEN

usage:

  me                                         get the current authenticated user
  org <org>                                  get an organization
  create_org_repo <repo> <private>           create a new (private <true | false>) github organization repository
  create_release                             create a new release based on the current version using the text from GITHUB_CHANGES
  upload_assets <release-id>                 upload GITHUB_ASSETS_ZIP to a release
  repos [<org>]                              list repositories (for the specified organization)
  teams                                      get teams
  add_team <team-id> <permission>            add a team with permission (pull, push, admin)
                                             e.g. bee github add_team 1234567 push
  remove_team <team-id>                      remove a team
  add_user <user-name> <permission>          add a user with permission (pull, push, admin, maintain, triage)
                                             e.g bee github add_user sschmid push
  remove_user <user-name>                    remove a user
  set_topics <topics>                        set repository topics
                                             e.g. bee github set_topics bash bee
  get_branch_protection <branch>             get branch protection
  update_branch_protection <branch> <data>   update branch protection
                                             e.g. bee github update_branch_protection main "${data}"
                                             data:
                                             {
                                               "required_status_checks": null,
                                               "enforce_admins": false,
                                               "required_pull_request_reviews": {
                                                 "dismissal_restrictions": {
                                                   "users": [],
                                                   "teams": []
                                                 },
                                                 "dismiss_stale_reviews": true,
                                                 "require_code_owner_reviews": false,
                                                 "required_approving_review_count": 1
                                               },
                                               "restrictions": null
                                             }

requirements:

  curl

EOF
}

github::me() {
  curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
    "https://api.github.com/user"
}

github::org() {
  local name="${1}"
  curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
    "https://api.github.com/orgs/${name}"
}

github::create_org_repo() {
  local name="$1" private="$2"
  curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
    -d "{\"name\": \"${name}\", \"private\": ${private}}" \
    "https://api.github.com/orgs/${GITHUB_ORG}/repos"
}

github::create_release() {
  local version changes data
  version="$(semver::read)"
  changes="$(cat "${GITHUB_CHANGES}")"
  changes="${changes//$'\n'/\\n}"
  data=$(cat << EOF
{
  "tag_name": "${version}",
  "name": "${GITHUB_RELEASE_PREFIX}${version}",
  "body": "${changes}"
}
EOF
  )
  curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
    -d "${data}" \
    "https://api.github.com/repos/${GITHUB_REPO}/releases"
}

github::upload_assets() {
  if [[ ${#GITHUB_ASSETS_ZIP[@]} -gt 0 ]]; then
    local id="$1" upload_url="https://uploads.github.com/repos/${GITHUB_REPO}/releases/${id}/assets"
    for zip in "${GITHUB_ASSETS_ZIP[@]}"; do
      curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Content-Type:application/zip" \
        --data-binary "@${zip}" \
        "${upload_url}"?name="$(basename "${zip}")"
    done
  fi
}

github::repos() {
  local org="${1:-$GITHUB_ORG}"
  curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/${org}/repos"
}

github::teams() {
  curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
    "https://api.github.com/repos/${GITHUB_REPO}/teams"
}

github::add_team() {
  local id="$1" permission="$2"
  local data="{\"permission\": \"${permission}\"}"
  curl -s -X PUT \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -d "${data}" \
    "https://api.github.com/organizations/${GITHUB_ORG_ID}/team/${id}/repos/${GITHUB_REPO}"
}

github::remove_team() {
  local id="$1"
  curl -s -X DELETE \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    "https://api.github.com/organizations/${GITHUB_ORG_ID}/team/${id}/repos/${GITHUB_REPO}"
}

github::add_user() {
  local user_name="$1" permission="$2"
  local data="{\"permission\": \"${permission}\"}"
  curl -s -X PUT \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -d "${data}" \
    "https://api.github.com/repos/${GITHUB_REPO}/collaborators/${user_name}"
}

github::remove_user() {
  local user_name="$1"
  curl -s -X DELETE \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    "https://api.github.com/repos/${GITHUB_REPO}/collaborators/${user_name}"
}

github::set_topics() {
  local -a topics=("$@") data
  topics=("${topics[@]/#/\"}")
  topics=("${topics[@]/%/\"}")
  data="{\"names\":[$(join_by "," "${topics[@]}")]}"
  curl -s -X PUT \
    -H "Authorization: token ${GITHUB_TOKEN}" \
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
  curl -s \
    -H "Accept: application/vnd.github.v3+json" \
    -u "${GITHUB_ORG}:${GITHUB_TOKEN}" \
    "https://api.github.com/repos/${GITHUB_REPO}/branches/${branch}/protection"
}

github::update_branch_protection() {
  local branch="$1" data="$2"
  curl -s \
    -X PUT \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Accept: application/vnd.github.luke-cage-preview+json" \
    -u "${GITHUB_ORG}:${GITHUB_TOKEN}" \
    -d "${data}" \
    "https://api.github.com/repos/${GITHUB_REPO}/branches/${branch}/protection"
}
