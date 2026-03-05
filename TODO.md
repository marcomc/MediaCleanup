# TODO

- Add support for renaming movie files using gemini-cli.
- Add a GUI.
- Create a brew package.

## Propositions
- [ ] **Debounce-based LaunchAgent for `mediacleanup`**  
  Wait for a configurable quiet window after the last filesystem event on each watched media folder before running `mediacleanup`, and serialize the timer so only one wrapper instance runs at a time.  
  - Draft a proposal covering the LaunchAgent, lock/state-file wrapper, and quiet-window behavior before writing scripts (see docs/planning/launchagent-debounce-proposal.md).
  - Create or update the LaunchAgent plist and wrapper script to implement the lock, timestamp sharing, and quiet-window logic with a configurable delay.
  - Document how to enable/disable the agent for a specific machine and how to adjust the quiet-window timeout per folder set.
