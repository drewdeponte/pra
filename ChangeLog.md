# ChangeLog

The following are lists of the notable changes included with each release.
This is inteded to help keep people informed about notable changes between
versions as well as provide a rough history.

#### Next Release

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

