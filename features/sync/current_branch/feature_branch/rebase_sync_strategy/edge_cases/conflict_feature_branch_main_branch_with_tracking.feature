Feature: handle conflicts between the current feature branch and the main branch (with tracking branch updates)

  Background:
    Given Git Town setting "sync-strategy" is "rebase"
    And the current branch is a feature branch "feature"
    And the commits
      | BRANCH  | LOCATION      | MESSAGE                    | FILE NAME        | FILE CONTENT    |
      | main    | local         | conflicting main commit    | conflicting_file | main content    |
      | feature | local, origin | conflicting feature commit | conflicting_file | feature content |
      |         | origin        | feature commit             | feature_file     | feature content |
    And an uncommitted file
    When I run "git-town sync"

  Scenario: result
    Then it runs the commands
      | BRANCH  | COMMAND                   |
      | feature | git fetch --prune --tags  |
      |         | git add -A                |
      |         | git stash                 |
      |         | git checkout main         |
      | main    | git rebase origin/main    |
      |         | git push                  |
      |         | git checkout feature      |
      | feature | git rebase origin/feature |
      |         | git rebase main           |
    And it prints the error:
      """
      CONFLICT (add/add): Merge conflict in conflicting_file
      """
    And it prints the error:
      """
      To abort, run "git-town abort".
      To continue after having resolved conflicts, run "git-town continue".
      To continue by skipping the current branch, run "git-town skip".
      """
    And the current branch is still "feature"
    And the uncommitted file is stashed
    And a rebase is now in progress

  Scenario: abort
    When I run "git-town abort"
    Then it runs the commands
      | BRANCH  | COMMAND                                                           |
      | feature | git rebase --abort                                                |
      |         | git reset --hard {{ sha-in-origin 'conflicting feature commit' }} |
      |         | git stash pop                                                     |
    And the current branch is still "feature"
    And the uncommitted file still exists
    And no rebase is in progress
    And now these commits exist
      | BRANCH  | LOCATION      | MESSAGE                    | FILE NAME        | FILE CONTENT    |
      | main    | local, origin | conflicting main commit    | conflicting_file | main content    |
      | feature | local, origin | conflicting feature commit | conflicting_file | feature content |
      |         | origin        | feature commit             | feature_file     | feature content |

  Scenario: continue with unresolved conflict
    When I run "git-town continue"
    Then it runs no commands
    And it prints the error:
      """
      you must resolve the conflicts before continuing
      """
    And the current branch is still "feature"
    And the uncommitted file is stashed
    And a rebase is now in progress

  Scenario: resolve and continue
    When I resolve the conflict in "conflicting_file"
    And I run "git-town continue" and enter "resolved commit" for the commit message
    Then it runs the commands
      | BRANCH  | COMMAND                     |
      | feature | git rebase --continue       |
      |         | git push --force-with-lease |
      |         | git stash pop               |
    And all branches are now synchronized
    And the current branch is still "feature"
    And no rebase is in progress
    And the uncommitted file still exists
    And these committed files exist now
      | BRANCH  | NAME             | CONTENT          |
      | main    | conflicting_file | main content     |
      | feature | conflicting_file | resolved content |
      |         | feature_file     | feature content  |

  Scenario: resolve, commit, and continue
    When I resolve the conflict in "conflicting_file"
    And I run "git rebase --continue" and enter "resolved commit" for the commit message
    And I run "git-town continue"
    Then it runs the commands
      | BRANCH  | COMMAND                     |
      | feature | git push --force-with-lease |
      |         | git stash pop               |
