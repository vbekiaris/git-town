package config_test

import (
	"testing"

	"github.com/git-town/git-town/v10/src/config"
	"github.com/shoenig/test/must"
)

func TestParseBool(t *testing.T) {
	t.Parallel()

	t.Run("yes/no", func(t *testing.T) {
		t.Parallel()
		verifyParseBool(t, map[string]bool{
			"yes": true,
			"no":  false,
		})
	})

	t.Run("on/off", func(t *testing.T) {
		t.Parallel()
		verifyParseBool(t, map[string]bool{
			"on":  true,
			"off": false,
		})
	})

	t.Run("true/false", func(t *testing.T) {
		t.Parallel()
		verifyParseBool(t, map[string]bool{
			"true":  true,
			"false": false,
		})
	})

	t.Run("numbers", func(t *testing.T) {
		t.Parallel()
		verifyParseBool(t, map[string]bool{
			"1": true,
			"0": false,
		})
	})

	t.Run("case insensitive", func(t *testing.T) {
		t.Parallel()
		for _, give := range []string{"yes", "Yes", "YES"} {
			have, err := config.ParseBool(give)
			must.NoError(t, err)
			must.EqOp(t, true, have)
		}
	})

	t.Run("invalid input", func(t *testing.T) {
		t.Parallel()
		_, err := config.ParseBool("zonk")
		must.Error(t, err)
	})
}

func verifyParseBool(t *testing.T, tests map[string]bool) {
	t.Helper()
	for give, want := range tests {
		have, err := config.ParseBool(give)
		must.NoError(t, err)
		must.EqOp(t, want, have)
	}
}
