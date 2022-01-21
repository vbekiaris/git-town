Feature: git-new-pull-request: on a feature branch with a upstream remote

  Background:
    Given my repo has an upstream repo
    And my repo's upstream is "git@github.com:git-town/git-town"
    And my repo's origin is "git@github.com:kevgo/git-town"
    And my repo has a feature branch named "feature"
    And the following commits exist in my repo
      | BRANCH  | LOCATION | MESSAGE         |
      | main    | upstream | upstream commit |
      | feature | local    | local commit    |
    And I am on the "feature" branch
    And my workspace has an uncommitted file
    And my computer has the "open" tool installed
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
    And I am still on the "feature" branch
    And my workspace still contains my uncommitted file
    And my repo now has the following commits
      | BRANCH  | LOCATION                | MESSAGE                          |
      | main    | local, remote, upstream | upstream commit                  |
      | feature | local, remote           | local commit                     |
      |         |                         | upstream commit                  |
      |         |                         | Merge branch 'main' into feature |
    And "open" launches a new pull request with this url in my browser:
      """
      https://github.com/kevgo/git-town/compare/feature?expand=1
      """
