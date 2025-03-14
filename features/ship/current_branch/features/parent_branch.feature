Feature: ship a parent branch

  Background:
    Given the current branch is a feature branch "parent"
    And a feature branch "child" as a child of "parent"
    And the commits
      | BRANCH | LOCATION      | MESSAGE       |
      | parent | local, origin | parent commit |
      | child  | local, origin | child commit  |
    When I run "git-town ship -m 'parent done'"

  Scenario: result
    Then it runs the commands
      | BRANCH | COMMAND                           |
      | parent | git fetch --prune --tags          |
      |        | git checkout main                 |
      | main   | git rebase origin/main            |
      |        | git checkout parent               |
      | parent | git merge --no-edit origin/parent |
      |        | git merge --no-edit main          |
      |        | git checkout main                 |
      | main   | git merge --squash parent         |
      |        | git commit -m "parent done"       |
      |        | git push                          |
      |        | git branch -D parent              |
    And it prints:
      """
      branch "child" is now a child of "main"
      """
    And the current branch is now "main"
    And now these commits exist
      | BRANCH | LOCATION      | MESSAGE       |
      | main   | local, origin | parent done   |
      | child  | local, origin | child commit  |
      | parent | origin        | parent commit |
    And this branch lineage exists now
      | BRANCH | PARENT |
      | child  | main   |

  Scenario: undo
    When I run "git-town undo"
    Then it runs the commands
      | BRANCH | COMMAND                                     |
      | main   | git revert {{ sha 'parent done' }}          |
      |        | git push                                    |
      |        | git branch parent {{ sha 'parent commit' }} |
      |        | git checkout parent                         |
    And the current branch is now "parent"
    And now these commits exist
      | BRANCH | LOCATION      | MESSAGE              |
      | main   | local, origin | parent done          |
      |        |               | Revert "parent done" |
      | child  | local, origin | child commit         |
      | parent | local, origin | parent commit        |
    And the initial branches and hierarchy exist
