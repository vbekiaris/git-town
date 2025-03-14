package config

import (
	"sort"

	"github.com/git-town/git-town/v10/src/domain"
	"github.com/git-town/git-town/v10/src/gohacks/slice"
	"golang.org/x/exp/maps"
)

// Lineage encapsulates all data and functionality around parent branches.
// branch --> its parent.
type Lineage map[domain.LocalBranchName]domain.LocalBranchName

// Ancestors provides the names of all parent branches of the branch with the given name.
func (self Lineage) Ancestors(branch domain.LocalBranchName) domain.LocalBranchNames {
	current := branch
	result := domain.LocalBranchNames{}
	for {
		parent, found := self[current]
		if !found {
			return result
		}
		result = append(domain.LocalBranchNames{parent}, result...)
		current = parent
	}
}

// BranchAndAncestors provides the full lineage for the branch with the given name,
// including the branch.
func (self Lineage) BranchAndAncestors(branchName domain.LocalBranchName) domain.LocalBranchNames {
	return append(self.Ancestors(branchName), branchName)
}

// BranchNames provides the names of all branches in this Lineage, sorted alphabetically.
func (self Lineage) BranchNames() domain.LocalBranchNames {
	result := domain.LocalBranchNames(maps.Keys(self))
	result.Sort()
	return result
}

// BranchesAndAncestors provides the full lineage for the branches with the given names,
// including the branches themselves.
func (self Lineage) BranchesAndAncestors(branchNames domain.LocalBranchNames) domain.LocalBranchNames {
	result := branchNames
	for _, branchName := range branchNames {
		ancestors := self.Ancestors(branchName)
		slice.AppendAllMissing(&result, ancestors)
	}
	self.OrderHierarchically(result)
	return result
}

// Children provides the names of all branches that have the given branch as their parent.
func (self Lineage) Children(branch domain.LocalBranchName) domain.LocalBranchNames {
	result := domain.LocalBranchNames{}
	for child, parent := range self {
		if parent == branch {
			result = append(result, child)
		}
	}
	result.Sort()
	return result
}

// HasParents returns whether or not the given branch has at least one parent.
func (self Lineage) HasParents(branch domain.LocalBranchName) bool {
	for child := range self {
		if child == branch {
			return true
		}
	}
	return false
}

// IsAncestor indicates whether the given branch is an ancestor of the other given branch.
func (self Lineage) IsAncestor(ancestor, other domain.LocalBranchName) bool {
	current := other
	for {
		parent, found := self[current]
		if !found {
			return false
		}
		if parent == ancestor {
			return true
		}
		current = parent
	}
}

// OrderHierarchically sorts the given branches in place so that ancestor branches come before their descendants
// and everything is sorted alphabetically.
func (self Lineage) OrderHierarchically(branches domain.LocalBranchNames) {
	sort.Slice(branches, func(a, b int) bool {
		first := branches[a]
		second := branches[b]
		if first.IsEmpty() {
			return true
		}
		if second.IsEmpty() {
			return false
		}
		if self.IsAncestor(first, second) {
			return true
		}
		if self.IsAncestor(second, first) {
			return false
		}
		return first.String() < second.String()
	})
}

// Parent provides the name of the parent branch for the given branch or nil if the branch has no parent.
func (self Lineage) Parent(branch domain.LocalBranchName) domain.LocalBranchName {
	for child, parent := range self {
		if child == branch {
			return parent
		}
	}
	return domain.EmptyLocalBranchName()
}

// RemoveBranch removes the given branch completely from this lineage.
func (self Lineage) RemoveBranch(branch domain.LocalBranchName) {
	parent := self.Parent(branch)
	for _, childName := range self.Children(branch) {
		if parent.IsEmpty() {
			delete(self, childName)
		} else {
			self[childName] = parent
		}
	}
	delete(self, branch)
}

// Roots provides the branches with children and no parents.
func (self Lineage) Roots() domain.LocalBranchNames {
	roots := domain.LocalBranchNames{}
	for _, parent := range self {
		_, found := self[parent]
		if !found && !slice.Contains(roots, parent) {
			roots = append(roots, parent)
		}
	}
	roots.Sort()
	return roots
}
