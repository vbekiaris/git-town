Feature: push-hook setting set to "true"

  Background:
    Given the current branch is a feature branch "feature"
    And the commits
      | BRANCH  | LOCATION | MESSAGE               |
      | main    | local    | local main commit     |
      |         | origin   | origin main commit    |
      | feature | local    | local feature commit  |
      |         | origin   | origin feature commit |
    And Git Town setting "push-hook" is "true"

  Scenario: result
    When I run "git-town sync"
    Then it runs the commands
      | BRANCH  | COMMAND                            |
      | feature | git fetch --prune --tags           |
      |         | git checkout main                  |
      | main    | git rebase origin/main             |
      |         | git push                           |
      |         | git checkout feature               |
      | feature | git merge --no-edit origin/feature |
      |         | git merge --no-edit main           |
      |         | git push                           |
    And all branches are now synchronized
    And the current branch is still "feature"
    And now these commits exist
      | BRANCH  | LOCATION      | MESSAGE                                                    |
      | main    | local, origin | origin main commit                                         |
      |         |               | local main commit                                          |
      | feature | local, origin | local feature commit                                       |
      |         |               | origin feature commit                                      |
      |         |               | Merge remote-tracking branch 'origin/feature' into feature |
      |         |               | origin main commit                                         |
      |         |               | local main commit                                          |
      |         |               | Merge branch 'main' into feature                           |

  Scenario: undo
    When I run "git-town undo"
    Then it prints the error:
      """
      nothing to undo
      """
    And it runs no commands
