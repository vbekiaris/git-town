Feature: sync a branch with unshipped local changes whose tracking branch was deleted

  Background:
    Given a feature branch "shipped"
    And the commits
      | BRANCH  | LOCATION      | MESSAGE          |
      | shipped | local, origin | shipped commit   |
      |         | local         | unshipped commit |
    And origin ships the "shipped" branch
    And the current branch is "shipped"
    And an uncommitted file
    When I run "git-town sync"

  Scenario: result
    Then it runs the commands
      | BRANCH  | COMMAND                  |
      | shipped | git fetch --prune --tags |
      |         | git add -A               |
      |         | git stash                |
      |         | git checkout main        |
      | main    | git rebase origin/main   |
      |         | git checkout shipped     |
      | shipped | git merge --no-edit main |
      |         | git stash pop            |
    And it prints:
      """
      Branch "shipped" was deleted at the remote but the local branch contains unshipped changes.
      """
    And the current branch is still "shipped"
    And the uncommitted file still exists
    And the initial branches and hierarchy exist

  Scenario: undo
    When I run "git-town undo"
    Then it runs the commands
      | BRANCH  | COMMAND                                     |
      | shipped | git add -A                                  |
      |         | git stash                                   |
      |         | git checkout main                           |
      | main    | git reset --hard {{ sha 'Initial commit' }} |
      |         | git checkout shipped                        |
      | shipped | git stash pop                               |
    And the current branch is now "shipped"
    And the uncommitted file still exists
    And now these commits exist
      | BRANCH  | LOCATION | MESSAGE          |
      | main    | origin   | shipped commit   |
      | shipped | local    | shipped commit   |
      |         |          | unshipped commit |
    And the initial branches and hierarchy exist
