package opcode

import (
	"github.com/git-town/git-town/v10/src/domain"
	"github.com/git-town/git-town/v10/src/vm/shared"
)

// MergeParent merges the branch that at runtime is the parent branch of the given branch into the given branch.
type MergeParent struct {
	CurrentBranch domain.LocalBranchName
	undeclaredOpcodeMethods
}

func (self *MergeParent) CreateAbortProgram() []shared.Opcode {
	return []shared.Opcode{
		&AbortMerge{},
	}
}

func (self *MergeParent) CreateContinueProgram() []shared.Opcode {
	return []shared.Opcode{
		&ContinueMerge{},
	}
}

func (self *MergeParent) Run(args shared.RunArgs) error {
	parent := args.Lineage.Parent(self.CurrentBranch)
	if parent.IsEmpty() {
		return nil
	}
	return args.Runner.Frontend.MergeBranchNoEdit(parent.BranchName())
}
