# TODO

A list of things that we still need to do with respect to this project. This
is a poor mans issue list because we are using Stash instead of GitHub and
Stash doesn't have a concept of issues. The reason we are using Stash instead
of GitHub is because Stash is internal and GitHub is public. Currently, the
project isn't quite ready to be released as open source therefore I am keeping
it in Stash for now.

## Todos

- Figure out how we want to handle failures when using the APIs and how we can
  notify the users. Users could have easily miss-configured the host, port,
  username, password, etc. Therefore, they could be getting a timeout, an
  unauthorized, etc. We need to decided how we should handle those scenarios.
  Currently, the app just dies with an exception.
- Need to figure out a way to ease the creation of the clipuller.json. It is
  actually a relatively involved JSON config file and it would be ideal if we
  had an easy way to get users started. Maybe we have a wizard like command
  where it prompts with some questions and based on the answers it generates
  a starting clipuller.json. If that is too involved for v1 we could simply
  provide a copy and pastable example in the README to get people going
  quickly.
- Add checking for the ~/.clipuller.json file and exit outputting a message to
  the user notifying them that the file can't be found and that it is
  required. It would also be nice to notify the user of what command would
  help them generate one, or if they just need a place to look to find an
  example.
- License the project under the MIT license.
