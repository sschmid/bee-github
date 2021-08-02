# github
Useful commands for GitHub

## `github::me`
Get the current authenticated user

## `github::org <org>`
Get an organization

### Example
```sh
bee github::org MyOrg
```

## `github::create_org_repo <repo> <private>`
Create a new github organization repository

### Example
```sh
bee github::create_org_repo MyApp true
```

## `github::create_release`
Create a new release based on the current version
using the text from `GITHUB_CHANGES`

## `github::upload_assets <release-id>`
Upload `GITHUB_ASSETS_ZIP` to a release

### Example
```sh
bee github::upload_assets 12345678
```

## `github::teams`
Get teams

## `github::add_team <team-id> <permission>`
Add a team with permission (pull, push, admin)

### Example
```sh
bee github::add_team 1234567 push
```

## `github::remove_team <team-id>`
Remove a team

### Example
```sh
bee github::remove_team 1234567
```

## `github::add_user <user-name> <permission>`
Add a user with permission (pull, push, admin, maintain, triage)

### Example
```sh
bee github::add_user sschmid push
```

## `github::remove_user <user-name>`
Remove a user

### Example
```sh
bee github::remove_user sschmid
```

## `github::set_topics <topics>`
Set repository topics

### Example
```sh
bee github::set_topics bash bee
```

## `github::get_branch_protection <branch>`
Get branch protection

## `github::update_branch_protection <branch> <data>`
Update branch protection

### Example
```sh
data=$(cat <<EOF
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
EOF
)
github::update_branch_protection main "${data}"
```
----------------------------------------

## Dependencies

### bee
- `version`

### 3rd party
- `curl`
