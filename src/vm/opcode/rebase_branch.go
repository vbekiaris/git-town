package opcode

import (
	"github.com/git-town/git-town/v10/src/domain"
	"github.com/git-town/git-town/v10/src/vm/shared"
)

// RebaseBranch rebases the current branch
// against the branch with the given name.
type RebaseBranch struct {
	Branch domain.BranchName
	undeclaredOpcodeMethods
}

func (self *RebaseBranch) CreateAbortProgram() []shared.Opcode {
	return []shared.Opcode{&AbortRebase{}}
}

func (self *RebaseBranch) CreateContinueProgram() []shared.Opcode {
	return []shared.Opcode{&ContinueRebase{}}
}

func (self *RebaseBranch) Run(args shared.RunArgs) error {
	return args.Runner.Frontend.Rebase(self.Branch)
}
