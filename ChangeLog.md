# ChangeLog

The following are lists of the notable changes included with each release.
This is inteded to help keep people informed about notable changes between
versions as well as provide a rough history.

#### Next Release
* Added ability to refresh pull requests
* Added pagination when there are more pull requests than can be displayed
* Added support for github organizations
* Added last refresh time to UI
* Redesgined pull request render process to make format changes easier
* Added github labels
* Changed github query method to reduce API calls and support organizations
* Added github rate limiting protection

#### v1.7.2

* Fix bug #2, left over PRs not clearing

#### v1.7.1

* Fix bug in curses windows system

#### v1.7.0

* Upgrade to latest gem standards
* Fix flash on navigation change
* Switch to default terminal color scheme
* Add light weight logging with timestamps
* Add Ruby 2.2.3 support
* Add Ruby 2.2.2 support

#### v1.6.0

* Switch to using Faraday instead of RestClient.

#### v1.5.1

* Fix bug where failed if no `assignee_blacklist` was found in config. Thanks
  to @gfmtim.

#### v1.5.0

* Upgraded dependency gems and moved to less pessimisitic versioning
  constraints on the dependencies.

#### v1.4.0

* Added `curses` as a gem dependency because in ruby version 2.1.0 they have
  removed `curses` from the standard lib. This can be seen in their [release
  notes](https://www.ruby-lang.org/en/news/2013/12/25/ruby-2-1-0-is-released/)
  as well as in one of their tickets
  [\#8584](https://bugs.ruby-lang.org/issues/8584).

#### v1.3.0

* Added support for Stash user profile repositories. This means you can now
  have `pra` watch not only your Stash project housed repositories but also
  your personal repositories that are housed under your Stash user profile.

#### v1.2.0

* Added Assignee blacklisting so that when you have a group user that
  represents a team assignment it can be blacklisted so that it doesn't show
  up as assigned.

#### v1.1.0

* Added "Assignee" column so that users can see which pull requests have
  already been assigned ([\#10](https://github.com/reachlocal/pra/issues/10))

#### v1.0.0

* Added connection failure handling so it stays running
  ([\#1](https://github.com/reachlocal/pra/issues/1))
* Added user notification of connection failures
  ([\#1](https://github.com/reachlocal/pra/issues/1))
* Added error logging to `~/.pra.error.log`
  ([\#1](https://github.com/reachlocal/pra/issues/1))

#### v0.1.1

* Fixed up the gemspec to include homepage on rubygems.org

#### v0.1.0

This is the first public release. It includes the following:

* Added ability to open selected pull request
* Made Pull Requests in the list selectable
* Listing of Pull Requests found to be open
* Support for pulling Pull Requests from GitHub
* Support for pulling Pull Requests from Stash

