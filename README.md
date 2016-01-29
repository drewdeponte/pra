# pra - The Pull-Request Aggregator

`pra` is a command line tool designed to allow developers to see the
current state of open pull-requests across multiple services. Currently, it
supports the following services:

- [GitHub](http://github.com)
- [Stash](http://www.atlassian.com/software/stash)

## Installation

You can easily install `pra` with the following command:

    $ gem install pra

## Configuration

`pra` requires one configuration, `~/.pra.json`, to exist in your home
directory. The following is an example config that can be used as a starter.
*Note:* You will need to replace **your.username**, **your.password**,
**your.stash.server**, and the **repositories** sections of each of the pull
sources.

    {
      "pull_sources": [
        {
          "type": "stash",
          "config": {
            "protocol": "https",
            "host": "your.stash.server",
            "username": "your.username",
            "password": "your.password",
            "repositories": [
              { "project_slug": "CAP", "repository_slug": "capture_api" },
              { "user_slug": "bob.villa", "repository_slug": "personal_notes" },
              { "project_slug": "RELENG", "repository_slug": "ramboo" }
            ]
          }
        },
        {
          "type": "github",
          "config": {
            "protocol": "https",
            "host": "api.github.com",
            "username": "your.username",
            "password": "your.password",
            "repositories": [
              { "owner": "reachlocal", "repository": "snapdragon" },
              { "owner": "brewster", "repository": "cequel" }
            ]
          }
        }
      ],
      "assignee_blacklist": [
        "IPT-Capture",
        "IPT-Core Services"
      ],
      "refresh_interval": 300
    }

I suggest copying and pasting the above starter file into your `~/.pra.json`
file to get you started. Then simply replace the appropriate fields and the
**repositories** sections for all the pull sources with the repository
information for the repositories you want to watch for open pull requests.

#### Stash User & Project Repositories

You may have noticed that the above example shows two repository objects in its
Stash **repositories** array.

1. Project Scoped Repository - `{ "project_slug": "CAP", "repository_slug": "capture_api" },`
2. User Scoped Repository - `{ "user_slug": "bob.villa", "repository_slug": "personal_notes" },`

This is because Stash has both the concept of repsositories that are organized
under Projects and repositories that are organized under Users. Therefore, you
would want to use the **User Scoped Repository** in scenarios where the
repository is housed under a user and the **Project Scoped Repository** in
scenarios where the repository is housed under a project.

#### Assignee Blacklist

Reduces noise to more easily determine which pull requests are unassigned. Names
added will not appear in the assignee column.

### GitHub Authentication

#### Multi-Factor Authentication

Sadly, at the moment `pra` doesn't support GitHub's Multi-Factor
Authentication. There is a ticket for this
( [\#5](https://github.com/reachlocal/pra/issues/5) ).

#### OAuth

It is also lacking support for GitHub's OAuth mechanism. There is a ticket for
this ( [\#6](https://github.com/reachlocal/pra/issues/6) ).

#### HTTP Basic Auth

The HTTP Basic Auth will work as long as you don't have multi-factor
authentication enabled for your account.

#### Personal Access Token

Personal Access Token authentication is currently supported and this is the
recommended authentication mechanism to use right now. It is the only
authentication mechanism you can use at the moment if you have multi-factor
authentication enabled.

Simply go to your GitHub **Account Settings**, select **Applications**, click
the **Create new token** button in the **Personal Access Token** section. Give
it the name "Pra" and submit. This will generate your personal access token.
Then simply put your personal access token in the `~/.pra.json` as your GitHub
username and "x-oauth-basic" as your GitHub password.

## Usage

Once you have configured `pra` as described above you can launch it by simply
running the following command:

    pra

Once it launches, it will use the information provided in the `~/.pra.json`
configuration file to fetch all the open pull requests and display them. Once,
the pull requests are displayed you can perorm any of the following actions.

### Move Selection Up

To move the selection up simply press either the `k` or the `up arrow` key.

### Move Selection Down

To move the selection down simply press either the `j` or `down arrow` key.

### Open Selected Pull Request

If you would like to open the currently selected pull request in your default
browser you can press either the `o` or `enter` key.

### Quit

If you decide you have had enough and  want to exit `pra` press the `q` key.

## Contributing

If you would like to contribute to the `pra` project. You can do so in the
following areas:

### Bug Reporting

As with all software I am sure `pra` will have some bugs. I would very much
appreciate any contributions of bug reports. These can be reported on the
[issues page](http://github.com/reachlocal/pra/issues) of the project.

### Feature Requests

The current state of `pra` is just the MVP (minimum viable product). This
means there is always room for growth. If you would like to contribute your
thoughts on features that you would like `pra` to have you can submit them on
the [issues page](http://github.com/reachlocal/pra/issues) of the project.

### Improve Documentation

If you would like to contribute documentation improvements you should follow
the directions below.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Writing Code

If you want to contribute by writing code for `pra` you need to know the
following:

##### Overview

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

##### RVM/rbenv

We use [RVM](http://rvm.io/) or [rbenv](https://github.com/sstephenson/rbenv)
with `pra` to encapsulate the dependency gems in our development environments.
Therefore, we have the `.ruby-version` file in the repository which define the
current version of ruby that we are developing with.

You should have [RVM](http://rvm.io) or
[rbenv](https://github.com/sstephenson/rbenv) installed of course and when you
change into the project root directory it should switch to the proper ruby
version if you have it intsalled via [RVM](http://rvm.io) or
[rbenv](https://github.com/sstephenson/rbenv).

If the proper version of ruby is NOT installed via [RVM](http://rvm.io) or
[rbenv](https://github.com/sstephenson/rbenv) you should first install that
version of ruby and then change out of the project root directory, then change
back into it and verify that you are in the proper ruby version.

##### Bundler

We use [Bundler](http://bundler.io/) to manage the development dependencies of
`pra`. Once you are setup with [RVM](http://rvm.io) or
[rbenv](https://github.com/sstephenson/rbenv) as described above you should be
able to install all the development dependencies using the following command:

    bundle

##### Test Driven Development

I developed `pra` using the TDD methodology with
[RSpec](http://www.relishapp.com/rspec) as the testing tool of choice.
Therefore, if you are going to contribute code to `pra` please TDD your code
changes using [RSpec](http://www.relishapp.com/rspec). If you do not submit
your changes with test coverage your request will likely be denied requesting
you add appropriate test coverage.

##### Run Development Version Manually

If you have setup [RVM](http://rvm.io) or
[rbenv](https://github.com/sstephenson/rbenv) as described above and installed
the development dependencies using [Bundler](http://bundler.io/) as described
above you should be able to run the development version of `pra` by running
the following command:

    bundle exec ./bin/pra

*Note:* The above of course assumes that you have a `~/.pra.json` file
already configured.
