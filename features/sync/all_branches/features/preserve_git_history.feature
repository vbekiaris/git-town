Feature: preserve the previous Git branch

  Background:
    Given the feature branches "previous" and "current"
    And the current branch is "current" and the previous branch is "previous"

  Scenario: current branch gone, previous branch exists
    Given origin deletes the "current" branch
    When I run "git-town sync --all"
    Then the current branch is now "previous"
    And the previous Git branch is still "previous"

  Scenario: current branch exists, previous branch gone
    Given origin deletes the "previous" branch
    When I run "git-town sync --all"
    Then the current branch is still "current"
    And the previous Git branch is now "main"

  Scenario: both branches deleted
    Given origin deletes the "previous" branch
    And origin deletes the "current" branch
    When I run "git-town sync --all"
    Then the current branch is now "main"
    And the previous Git branch is now "main"

  Scenario: both branches exist
    When I run "git-town sync --all"
    Then the current branch is still "current"
    And the previous Git branch is still "previous"
