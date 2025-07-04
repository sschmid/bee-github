# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.2.0] - 2025-06-15
### Fixed
- Fix `github::upload_assets`

## [2.1.0] - 2025-06-15
### Added
- Add `github::releases`
- Add `github::runs`
- Add `github::artifacts`
- Add `github::download`

### Changed
- Use `curl -s` for silent output

## [2.0.0] - 2022-01-30
### Changed
- Update plugin according to bee 1.0.0 specs

## [1.1.0] - 2021-08-02
### Added
- Add `github::get_branch_protection`
- Add `github::update_branch_protection`

## [1.0.0] - 2021-03-13
bee-0.39.0 removed all plugins and added support for plugin registries
like the official beehub: https://github.com/sschmid/beehub

This is the initial version that contains all changes up to bee-0.39.0.
The code has been refactored and updated to follow the bee conventions.

[Unreleased]: https://github.com/sschmid/bee-github/compare/2.2.0...HEAD
[2.2.0]: https://github.com/sschmid/bee-github/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/sschmid/bee-github/compare/2.0.0...2.1.0
[2.0.0]: https://github.com/sschmid/bee-github/compare/1.1.0...2.0.0
[1.1.0]: https://github.com/sschmid/bee-github/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/sschmid/bee-github/releases/tag/1.0.0
