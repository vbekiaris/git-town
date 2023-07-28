package config_test

import (
	"testing"

	"github.com/git-town/git-town/v9/src/config"
	"github.com/stretchr/testify/assert"
)

func TestRemotes(t *testing.T) {
	t.Parallel()
	t.Run("HasOrigin", func(t *testing.T) {
		t.Parallel()
		t.Run("origin remote exists", func(t *testing.T) {
			t.Parallel()
			remotes := config.Remotes{"origin"}
			assert.True(t, remotes.HasOrigin())
		})
		t.Run("origin remote does not exist", func(t *testing.T) {
			t.Parallel()
			remotes := config.Remotes{"foo"}
			assert.False(t, remotes.HasOrigin())
		})
	})
	t.Run("HasUpstream", func(t *testing.T) {
		t.Parallel()
		t.Run("upstream remote exists", func(t *testing.T) {
			t.Parallel()
			remotes := config.Remotes{"upstream"}
			assert.True(t, remotes.HasUpstream())
		})
		t.Run("upstream remote does not exist", func(t *testing.T) {
			t.Parallel()
			remotes := config.Remotes{"foo"}
			assert.False(t, remotes.HasUpstream())
		})
	})
}