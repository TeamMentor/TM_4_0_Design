### Contributing to TeamMentor 4.0

:+1: First off, thanks for taking the time to contribute! :+1:

The following is a set of guidelines for contributing to TeamMentor and its packages,
which are hosted in the [TeamMentor Organization](https://github.com/TeamMentor) on GitHub.

#### Submitting Issues

* Check the [GitHub Issues Definitions](https://github.com/TeamMentor/TM_4_0_Design/wiki/GitHub-Issues-Definitions) for
our Issue's label defintions
* Include screenshots and animated GIFs whenever possible; they are immensely
  helpful.
* Include the behavior you expected and other places you've seen that behavior
* Check the dev tools (`alt-cmd-i`) for errors to include. If the dev tools
  are open _before_ the error is triggered, a full stack trace for the error
  will be logged. If you can reproduce the error, use this approach to get the
  full stack trace and include it in the issue.
* Perform a cursory search to see if a similar issue has already been submitted.

#### Package Repositories

This is the repository for the TeamMentor 4.0 Design only.

See [TM-Repos-build-status](https://github.com/TeamMentor/TM_4_0_Design/wiki/TM-Repos-build-status) for the
other relevant repos

### Pull Requests

* Include screenshots and animated GIFs in your pull request whenever possible.
* Follow the [CoffeeScript](#coffeescript-styleguide),
  [JavaScript](https://github.com/styleguide/javascript),
  and [CSS](https://github.com/styleguide/css) styleguides.
* Include thoughtfully-worded, well-structured tests.
* End files with a newline.

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally

### CoffeeScript Styleguide

* Set parameter defaults without spaces around the equal sign
    * `clear = (count=1) ->` instead of `clear = (count = 1) ->`
* Use parentheses if it improves code clarity.
* Prefer alphabetic keywords to symbolic keywords:
    * `a is b` instead of `a == b`
* Avoid spaces inside the curly-braces of hash literals:
    * `{a: 1, b: 2}` instead of `{ a: 1, b: 2 }`
* Include a single line of whitespace between methods.
* Capitalize initialisms and acronyms in names, except for the first word, which
  should be lower-case:
  * `getURI` instead of `getUri`
  * `uriToOpen` instead of `URIToOpen`
