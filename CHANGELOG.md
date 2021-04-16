# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.4.0]

### Changed

- Bump the keycloak helm chart version from 9.9.1 to 10.3.0 ([#6])

## [v0.3.0]

### Changed

- Rename keycloak:hostname to keycloak:fqdn([#5])
- Make external db vendor unspecific ([#4])

### Breaking Changes

Renamed variables:
- keycloak:hostname -> keycloak:fqdn
- keycloak:postgres:builtin -> keycloak:database:builtin
- keycloak:postgres:external:address -> keycloak:database:external:host
- keycloak:postgres:external:port -> keycloak:database:external:port
- keycloak:postgres:external:database -> keycloak:database:external:database
- keycloak:postgres:external:user -> keycloak:database:external:username
- keycloak:postgres:external:password -> keycloak:database:external:password

## [v0.2.0]

### Changed

- Make helm_values overwritable (#3])

## [v0.1.0]

### Added

- Initial open-source implementation ([#1])

[Unreleased]: https://github.com/projectsyn/component-keycloak/compare/v0.4.0...HEAD
[v0.1.0]: https://github.com/projectsyn/component-keycloak/releases/tag/v0.1.0
[v0.2.0]: https://github.com/projectsyn/component-keycloak/releases/tag/v0.2.0
[v0.3.0]: https://github.com/projectsyn/component-keycloak/releases/tag/v0.3.0
[v0.4.0]: https://github.com/projectsyn/component-keycloak/releases/tag/v0.4.0

[#1]: https://github.com/projectsyn/component-keycloak/pull/1
[#3]: https://github.com/projectsyn/component-keycloak/pull/3
[#4]: https://github.com/projectsyn/component-keycloak/pull/4
[#5]: https://github.com/projectsyn/component-keycloak/pull/5
[#6]: https://github.com/projectsyn/component-keyclaok/pull/6
