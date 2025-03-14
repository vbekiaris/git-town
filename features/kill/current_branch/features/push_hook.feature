Feature: undo deleting the current feature branch with disabled push-hook

  Background:
    Given the current branch is a feature branch "current"
    And a feature branch "other"
    And the commits
      | BRANCH  | LOCATION      | MESSAGE        |
      | current | local, origin | current commit |
      | other   | local, origin | other commit   |
    And an uncommitted file

  Scenario: set to "false"
    Given Git Town setting "push-hook" is "false"
    When I run "git-town kill"
    And I run "git-town undo"
    Then it runs the commands
      | BRANCH  | COMMAND                                                                   |
      | main    | git push --no-verify origin {{ sha 'current commit' }}:refs/heads/current |
      |         | git branch current {{ sha 'WIP on current' }}                             |
      |         | git checkout current                                                      |
      | current | git reset --soft HEAD^                                                    |
    And the current branch is now "current"
    And the uncommitted file still exists
    And now the initial commits exist
    And the initial branches and hierarchy exist

  Scenario: set to "true"
    Given Git Town setting "push-hook" is "true"
    When I run "git-town kill"
    And I run "git-town undo"
    Then it runs the commands
      | BRANCH  | COMMAND                                                       |
      | main    | git push origin {{ sha 'current commit' }}:refs/heads/current |
      |         | git branch current {{ sha 'WIP on current' }}                 |
      |         | git checkout current                                          |
      | current | git reset --soft HEAD^                                        |
    And the current branch is now "current"
    And the uncommitted file still exists
    And now the initial commits exist
    And the initial branches and hierarchy exist
