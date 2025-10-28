# Drydocker Contribution Guidelines

- Use Minitest for automated tests. Place new suites in `test/**/*_test.rb` and load them via the helper in `test/test_helper.rb`.
- Prefer standard library solutions before introducing new gem dependencies. If an external package is required, document the reason in the pull request.
- Keep the Docker workflow validated with tests that exercise the `Dockerfile` or related command builders.
