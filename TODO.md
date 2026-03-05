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
- [ ] **Assess move/cleanup ordering to avoid redundant operations**  
  Evaluate whether the current pipeline can remove unwanted files before moving/normalizing while keeping all valid media intact, or identify less disruptive optimizations to reduce redundant passes.  
  - Create docs/planning/removal-order-proposal.md outlining the current sequence, the risks of pre-cleanup deletes, and the acceptance criteria for any new ordering.
  - Experiment with virtual dry-run scenarios where removal runs first; verify that no media is dropped and record the observed behaviors in the proposal.
  - If a strict reorder proves unsafe, analyze alternatives such as merging removal with later scans or skipping nested-to-root for already-conforming files, and document next steps for implementation.
