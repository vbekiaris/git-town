Feature: multiple shipped branches

  Background:
    Given the feature branches "feature-1", "feature-2", and "feature-3"
    And the commits
      | BRANCH    | LOCATION      | MESSAGE          | FILE NAME      | FILE CONTENT      |
      | feature-1 | local, origin | feature-1 commit | feature-1-file | feature 1 content |
      | feature-2 | local, origin | feature-2 commit | feature-2-file | feature 2 content |
      | feature-3 | local, origin | feature-3 commit | feature-3-file | feature 3 content |
    And origin ships the "feature-1" branch
    And origin ships the "feature-2" branch
    And the current branch is "feature-3"
    When I run "git-town sync --all"

  Scenario: result
    Then it runs the commands
      | BRANCH    | COMMAND                              |
      | feature-3 | git fetch --prune --tags             |
      |           | git checkout main                    |
      | main      | git rebase origin/main               |
      |           | git checkout feature-1               |
      | feature-1 | git merge --no-edit main             |
      |           | git checkout main                    |
      | main      | git branch -d feature-1              |
      |           | git checkout feature-2               |
      | feature-2 | git merge --no-edit main             |
      |           | git checkout main                    |
      | main      | git branch -d feature-2              |
      |           | git checkout feature-3               |
      | feature-3 | git merge --no-edit origin/feature-3 |
      |           | git merge --no-edit main             |
      |           | git push                             |
      |           | git push --tags                      |
    And it prints:
      """
      deleted branch "feature-1"
      """
    And it prints:
      """
      deleted branch "feature-2"
      """
    And the current branch is still "feature-3"
    And the branches are now
      | REPOSITORY    | BRANCHES        |
      | local, origin | main, feature-3 |
    And this branch lineage exists now
      | BRANCH    | PARENT |
      | feature-3 | main   |

  Scenario: undo
    When I run "git-town undo"
    Then it runs the commands
      | BRANCH    | COMMAND                                           |
      | feature-3 | git reset --hard {{ sha 'feature-3 commit' }}     |
      |           | git push --force-with-lease                       |
      |           | git checkout main                                 |
      | main      | git reset --hard {{ sha 'Initial commit' }}       |
      |           | git branch feature-1 {{ sha 'feature-1 commit' }} |
      |           | git branch feature-2 {{ sha 'feature-2 commit' }} |
      |           | git checkout feature-3                            |
    And the current branch is still "feature-3"
    And the initial branches and hierarchy exist
