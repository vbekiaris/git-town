# offline

```
git-town.offline=<true|false>
```

If you have no internet connection, certain Git Town commands will fail trying
to keep the local repository in sync with it's remote counterparts. Enabling
offline mode via the [git town offline](../commands/offline.md) command prevents
this. In offline mode, Git Town omits all network operations.