Feature: git sync: resolving conflicting remote feature branch updates when syncing a feature branch without open changes

  (see ./pull_feature_branch_conflict_with_open_changes.feature)


  Background:
    Given I have a feature branch named "feature"
    And the following commits exist in my repository
      | BRANCH  | LOCATION | MESSAGE                   | FILE NAME        | FILE CONTENT               |
      | feature | remote   | remote conflicting commit | conflicting_file | remote conflicting content |
      |         | local    | local conflicting commit  | conflicting_file | local conflicting content  |
    And I am on the "feature" branch
    And I run `git sync` while allowing errors


  Scenario: result
    Then it runs the Git commands
      | BRANCH  | COMMAND                            |
      | feature | git checkout main                  |
      | main    | git fetch --prune                  |
      | main    | git rebase origin/main             |
      | main    | git checkout feature               |
      | feature | git merge --no-edit origin/feature |
    And I am still on the "feature" branch
    And my repo has a merge in progress


  Scenario: aborting
    When I run `git sync --abort`
    Then it runs the Git commands
      | BRANCH  | COMMAND              |
      | feature | git merge --abort    |
      | feature | git checkout main    |
      | main    | git checkout feature |
    And I am still on the "feature" branch
    And there is no merge in progress
    And I still have the following commits
      | BRANCH  | LOCATION | MESSAGE                   | FILE NAME        |
      | feature | local    | local conflicting commit  | conflicting_file |
      |         | remote   | remote conflicting commit | conflicting_file |
    And I still have the following committed files
      | BRANCH  | FILES            | CONTENT                   |
      | feature | conflicting_file | local conflicting content |


  Scenario: continuing without resolving conflicts
    When I run `git sync --continue` while allowing errors
    Then I get the error "You must resolve the conflicts before continuing the git sync"
    And I am still on the "feature" branch
    And my repo still has a merge in progress


  Scenario: continuing after resolving conflicts
    Given I resolve the conflict in "conflicting_file"
    When I run `git sync --continue`
    Then it runs the Git commands
      | BRANCH  | COMMAND                  |
      | feature | git commit --no-edit     |
      | feature | git merge --no-edit main |
      | feature | git push                 |
    And I am still on the "feature" branch
    And now I have the following commits
      | BRANCH  | LOCATION         | MESSAGE                                                    | FILE NAME        |
      | feature | local and remote | Merge remote-tracking branch 'origin/feature' into feature |                  |
      |         |                  | remote conflicting commit                                  | conflicting_file |
      |         |                  | local conflicting commit                                   | conflicting_file |
    And now I have the following committed files
      | BRANCH  | FILES            | CONTENT          |
      | feature | conflicting_file | resolved content |


  Scenario: continuing after resolving conflicts
    Given I resolve the conflict in "conflicting_file"
    When I run `git commit --no-edit; git sync --continue`
    Then it runs the Git commands
      | BRANCH  | COMMAND                  |
      | feature | git merge --no-edit main |
      | feature | git push                 |
    And I am still on the "feature" branch
    And now I have the following commits
      | BRANCH  | LOCATION         | MESSAGE                                                    | FILE NAME        |
      | feature | local and remote | Merge remote-tracking branch 'origin/feature' into feature |                  |
      |         |                  | remote conflicting commit                                  | conflicting_file |
      |         |                  | local conflicting commit                                   | conflicting_file |
    And now I have the following committed files
      | BRANCH  | FILES            | CONTENT          |
      | feature | conflicting_file | resolved content |
