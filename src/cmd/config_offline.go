package cmd

import (
	"fmt"

	"github.com/git-town/git-town/v10/src/cli/flags"
	"github.com/git-town/git-town/v10/src/cli/format"
	"github.com/git-town/git-town/v10/src/cli/io"
	"github.com/git-town/git-town/v10/src/config"
	"github.com/git-town/git-town/v10/src/execute"
	"github.com/git-town/git-town/v10/src/git"
	"github.com/git-town/git-town/v10/src/messages"
	"github.com/spf13/cobra"
)

const offlineDesc = "Displays or sets offline mode"

const offlineHelp = `
Git Town avoids network operations in offline mode.`

func offlineCmd() *cobra.Command {
	addVerboseFlag, readVerboseFlag := flags.Verbose()
	cmd := cobra.Command{
		Use:   "offline [(yes | no)]",
		Args:  cobra.MaximumNArgs(1),
		Short: offlineDesc,
		Long:  long(offlineDesc, offlineHelp),
		RunE: func(cmd *cobra.Command, args []string) error {
			return executeOffline(args, readVerboseFlag(cmd))
		},
	}
	addVerboseFlag(&cmd)
	return &cmd
}

func executeOffline(args []string, verbose bool) error {
	repo, err := execute.OpenRepo(execute.OpenRepoArgs{
		Verbose:          verbose,
		DryRun:           false,
		OmitBranchNames:  true,
		PrintCommands:    true,
		ValidateIsOnline: false,
		ValidateGitRepo:  false,
	})
	if err != nil {
		return err
	}
	if len(args) > 0 {
		return setOfflineStatus(args[0], &repo.Runner)
	}
	return displayOfflineStatus(&repo.Runner)
}

func displayOfflineStatus(run *git.ProdRunner) error {
	isOffline, err := run.Config.IsOffline()
	if err != nil {
		return err
	}
	io.Println(format.Bool(isOffline))
	return nil
}

func setOfflineStatus(text string, run *git.ProdRunner) error {
	value, err := config.ParseBool(text)
	if err != nil {
		return fmt.Errorf(messages.ValueInvalid, config.KeyOffline, text)
	}
	return run.Config.SetOffline(value)
}
