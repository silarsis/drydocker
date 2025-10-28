# drydocker

[![wercker status](https://app.wercker.com/status/b00d4339862ef12b880f0022b6d20b2a/m "wercker status")](https://app.wercker.com/project/bykey/b00d4339862ef12b880f0022b6d20b2a)
[![Code Climate](https://codeclimate.com/github/silarsis/drydocker/badges/gpa.svg)](https://codeclimate.com/github/silarsis/drydocker)
[![Test Coverage](https://codeclimate.com/github/silarsis/drydocker/badges/coverage.svg)](https://codeclimate.com/github/silarsis/drydocker)

Drydocker provides a simple wrapper to run tests inside a container every
time you make a change to your code. It listens to filesystem changes on your
host and runs a docker command every time it detects anything. It is a
pre-requisite of use that you have a docker image you can run your tests in.

## Installation

Drydocker can be installed as a gem - `gem install drydocker` (or, on OS X,
`sudo gem install drydocker`)

## Usage

When installed as a gem, you will have a `drydocker` executable. Running with
`-h` will provide up-to-date usage instructions.

Basic usage is to run `drydocker` in the top level directory of the project
you're working on - by default, it will mount that directory into an image
that has enough for running rspec installed, and will run `rspec spec` every
time it sees a change in the directory.

You can specify particular images to run in and commands to run at command line
if you need to run your tests in a different way or container. Please refer to
the output of `drydocker -h` for more information on the flags to use.

## Notes for contributors

- The file watching logic is now bundled with the gem, so you no longer need to
  install the third-party `listen` gem in order to monitor for changes.
- The included Dockerfile is validated by automated tests and targets Ruby 3.2
  with the Docker CLI available in the image.
- Run `bundle exec rake test` to execute the Minitest-based test suite.

## Contributing to drydocker

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Create a Pull Request.

## Links

* Source code:      <https://github.com/silarsis/drydocker>
* Build/Test:       <https://app.wercker.com/#applications/54b446f6da3a4af764100e91>
* Docker container: <https://registry.hub.docker.com/u/silarsis/drydocker/>
* RubyGem:          <https://rubygems.org/gems/drydocker>

## Releasing

Checkout the code, make changes, run `rake version:bump:minor`
(see <https://github.com/technicalpickles/jeweler#version-bumping> for options),
`git push` - wercker will do the rest.

## Copyright

Copyright (c) 2015 Kevin Littlejohn. See LICENSE.txt for
further details.
