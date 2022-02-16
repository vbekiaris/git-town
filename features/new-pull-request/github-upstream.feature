Feature: git-new-pull-request: on a feature branch with a upstream remote

  Background:
    Given an upstream repo
    And my repo's upstream is "git@github.com:git-town/git-town"
    And the origin is "git@github.com:kevgo/git-town"
    And a feature branch "feature"
    And the commits
      | BRANCH  | LOCATION | MESSAGE         |
      | main    | upstream | upstream commit |
      | feature | local    | local commit    |
    And the current branch is "feature"
    And an uncommitted file
    And tool "open" is installed
    When I run "git-town new-pull-request"


  Scenario: result
    Then it runs the commands
      | BRANCH  | COMMAND                                                         |
      | feature | git fetch --prune --tags                                        |
      |         | git add -A                                                      |
      |         | git stash                                                       |
      |         | git checkout main                                               |
      | main    | git rebase origin/main                                          |
      |         | git fetch upstream main                                         |
      |         | git rebase upstream/main                                        |
      |         | git push                                                        |
      |         | git checkout feature                                            |
      | feature | git merge --no-edit origin/feature                              |
      |         | git merge --no-edit main                                        |
      |         | git push                                                        |
      |         | git stash pop                                                   |
      | <none>  | open https://github.com/kevgo/git-town/compare/feature?expand=1 |
    And the current branch is still "feature"
    And the uncommitted file still exists
    And now these commits exist
      | BRANCH  | LOCATION                | MESSAGE                          |
      | main    | local, origin, upstream | upstream commit                  |
      | feature | local, origin           | local commit                     |
      |         |                         | upstream commit                  |
      |         |                         | Merge branch 'main' into feature |
    And "open" launches a new pull request with this url in my browser:
      """
      https://github.com/kevgo/git-town/compare/feature?expand=1
      """
