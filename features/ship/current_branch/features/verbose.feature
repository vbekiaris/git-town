Feature: display all executed Git commands

  Background:
    Given the current branch is a feature branch "feature"
    And the commits
      | BRANCH  | LOCATION      | MESSAGE        |
      | feature | local, origin | feature commit |

  Scenario: result
    When I run "git-town ship -m done --verbose"
    Then it runs the commands
      | BRANCH  | TYPE     | COMMAND                                           |
      |         | backend  | git version                                       |
      |         | backend  | git config -lz --global                           |
      |         | backend  | git config -lz --local                            |
      |         | backend  | git rev-parse --show-toplevel                     |
      |         | backend  | git stash list                                    |
      |         | backend  | git branch -vva                                   |
      |         | backend  | git status --long --ignore-submodules                    |
      |         | backend  | git remote                                        |
      | feature | frontend | git fetch --prune --tags                          |
      |         | backend  | git branch -vva                                   |
      |         | backend  | git rev-parse --verify --abbrev-ref @{-1}         |
      |         | backend  | git status --long --ignore-submodules                    |
      |         | backend  | git remote get-url origin                         |
      |         | backend  | git status --long --ignore-submodules                    |
      | feature | frontend | git checkout main                                 |
      | main    | frontend | git rebase origin/main                            |
      |         | backend  | git rev-list --left-right main...origin/main      |
      | main    | frontend | git checkout feature                              |
      | feature | frontend | git merge --no-edit origin/feature                |
      |         | frontend | git merge --no-edit main                          |
      |         | backend  | git diff main..feature                            |
      | feature | frontend | git checkout main                                 |
      | main    | frontend | git merge --squash feature                        |
      |         | backend  | git shortlog -s -n -e main..feature               |
      |         | backend  | git config user.name                              |
      |         | backend  | git config user.email                             |
      | main    | frontend | git commit -m done                                |
      |         | backend  | git rev-parse --short main                        |
      |         | backend  | git rev-list --left-right main...origin/main      |
      | main    | frontend | git push                                          |
      |         | frontend | git push origin :feature                          |
      |         | backend  | git log main..feature                             |
      | main    | frontend | git branch -D feature                             |
      |         | backend  | git config --unset git-town-branch.feature.parent |
      |         | backend  | git show-ref --quiet refs/heads/feature           |
      |         | backend  | git rev-parse --verify --abbrev-ref @{-1}         |
      |         | backend  | git checkout main                                 |
      |         | backend  | git checkout main                                 |
      |         | backend  | git config -lz --global                           |
      |         | backend  | git config -lz --local                            |
      |         | backend  | git branch -vva                                   |
      |         | backend  | git stash list                                    |
    And it prints:
      """
      Ran 42 shell commands.
      """
    And the current branch is now "main"

  Scenario: undo
    Given I ran "git-town ship -m done"
    When I run "git-town undo --verbose"
    Then it runs the commands
      | BRANCH | TYPE     | COMMAND                                        |
      |        | backend  | git version                                    |
      |        | backend  | git config -lz --global                        |
      |        | backend  | git config -lz --local                         |
      |        | backend  | git rev-parse --show-toplevel                  |
      |        | backend  | git stash list                                 |
      |        | backend  | git branch -vva                                |
      |        | backend  | git rev-parse --verify --abbrev-ref @{-1}      |
      |        | backend  | git status --long --ignore-submodules                 |
      |        | backend  | git config git-town-branch.feature.parent main |
      |        | backend  | git log --pretty=format:%h -10                 |
      | main   | frontend | git revert {{ sha 'done' }}                    |
      |        | backend  | git rev-list --left-right main...origin/main   |
      | main   | frontend | git push                                       |
      |        | frontend | git branch feature {{ sha 'feature commit' }}  |
      |        | frontend | git push -u origin feature                     |
      |        | frontend | git checkout feature                           |
      |        | backend  | git show-ref --quiet refs/heads/main           |
      |        | backend  | git rev-parse --verify --abbrev-ref @{-1}      |
      |        | backend  | git config -lz --global                        |
      |        | backend  | git config -lz --local                         |
      |        | backend  | git branch -vva                                |
      |        | backend  | git stash list                                 |
    And it prints:
      """
      Ran 22 shell commands.
      """
    And the current branch is now "feature"
