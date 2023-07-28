package runstate

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/git-town/git-town/v9/src/messages"
)

// Load loads the run state for the given Git repo from disk. Can return nil if there is no saved runstate.
func Load(repoDir string) (*RunState, error) {
	filename, err := PersistenceFilePath(repoDir)
	if err != nil {
		return nil, err
	}
	_, err = os.Stat(filename)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, nil //nolint:nilnil
		}
		return nil, fmt.Errorf(messages.FileStatProblem, filename, err)
	}
	var runState RunState
	content, err := os.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf(messages.FileReadProblem, filename, err)
	}
	err = json.Unmarshal(content, &runState)
	if err != nil {
		return nil, fmt.Errorf(messages.FileContentInvalidJSON, filename, err)
	}
	return &runState, nil
}

// Delete removes the stored run state from disk.
func Delete(repoDir string) error {
	filename, err := PersistenceFilePath(repoDir)
	if err != nil {
		return err
	}
	_, err = os.Stat(filename)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return fmt.Errorf(messages.FileStatProblem, filename, err)
	}
	err = os.Remove(filename)
	if err != nil {
		return fmt.Errorf(messages.FileDeleteProblem, filename, err)
	}
	return nil
}

// Save stores the given run state for the given Git repo to disk.
func Save(runState *RunState, repoDir string) error {
	content, err := json.MarshalIndent(runState, "", "  ")
	if err != nil {
		return fmt.Errorf(messages.RunstateSerializeProblem, err)
	}
	persistencePath, err := PersistenceFilePath(repoDir)
	if err != nil {
		return err
	}
	persistenceDir := filepath.Dir(persistencePath)
	err = os.MkdirAll(persistenceDir, 0o700)
	if err != nil {
		return err
	}
	err = os.WriteFile(persistencePath, content, 0o600)
	if err != nil {
		return fmt.Errorf(messages.FileWriteProblem, persistencePath, err)
	}
	return nil
}

func PersistenceFilePath(repoDir string) (string, error) {
	configDir, err := os.UserConfigDir()
	if err != nil {
		return "", fmt.Errorf(messages.RunstatePathProblem, err)
	}
	persistenceDir := filepath.Join(configDir, "git-town", "runstate")
	filename := SanitizePath(repoDir)
	return filepath.Join(persistenceDir, filename+".json"), err
}

func SanitizePath(dir string) string {
	replaceCharacterRE := regexp.MustCompile("[[:^alnum:]]")
	sanitized := replaceCharacterRE.ReplaceAllString(dir, "-")
	sanitized = strings.ToLower(sanitized)
	replaceDoubleMinusRE := regexp.MustCompile("--+") // two or more dashes
	sanitized = replaceDoubleMinusRE.ReplaceAllString(sanitized, "-")
	for strings.HasPrefix(sanitized, "-") {
		sanitized = sanitized[1:]
	}
	return sanitized
}
