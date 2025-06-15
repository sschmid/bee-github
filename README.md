# github
Useful functions for GitHub

https://github.com/sschmid/bee-github

```
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
  releases [<params>]                        list releases
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
  runs [<params>]                            list workflow runs
  artifacts [<run-id>]                       list artifacts for a workflow run
  download <artifact-id> <artifact-name>     download an artifact from a workflow run

requirements:

  curl
```
