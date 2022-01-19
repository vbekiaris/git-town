package envlist_test

import (
	"testing"

	"github.com/git-town/git-town/v7/src/envlist"
	"github.com/stretchr/testify/assert"
)

func TestPrependPath_containsPath(t *testing.T) {
	t.Parallel()
	give := []string{"ONE=1", "PATH=alpha:beta", "THREE=3"}
	have := envlist.PrependPath(give, "gamma")
	want := []string{"ONE=1", "PATH=gamma:alpha:beta", "THREE=3"}
	assert.Equal(t, have, want)
}

func TestPrependPath_withoutPath(t *testing.T) {
	t.Parallel()
	give := []string{"ONE=1", "TWO=2"}
	have := envlist.PrependPath(give, "alpha")
	want := []string{"ONE=1", "TWO=2", "PATH=alpha"}
	assert.Equal(t, have, want)
}

func TestReplace_containsKey(t *testing.T) {
	t.Parallel()
	give := []string{"ONE=1", "TWO=2", "THREE=3"}
	have := envlist.Replace(give, "TWO", "another")
	want := []string{"ONE=1", "TWO=another", "THREE=3"}
	assert.Equal(t, have, want)
}

func TestReplace_withoutKey(t *testing.T) {
	t.Parallel()
	give := []string{"ONE=1", "TWO=2"}
	have := envlist.Replace(give, "THREE", "new")
	want := []string{"ONE=1", "TWO=2", "THREE=new"}
	assert.Equal(t, have, want)
}