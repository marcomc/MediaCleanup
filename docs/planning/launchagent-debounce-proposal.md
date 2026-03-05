# LaunchAgent debounce wrapper for mediacleanup

## Summary
Describe a LaunchAgent-based watcher for the media directories that fires the `mediacleanup` script only after a configurable quiet window of filesystem inactivity, preventing partially synced data from triggering cleanup runs.

## Motivation
Some monitored directories are backed by cloud sync clients (Google Drive, pCloud) that emit bursts of events when folders sync. A cleanup job triggered while the service is still writing large files or finishing a folder sync can see incomplete downloads and either take unnecessary time or fail. A simple debounce ensures we only run after activity settles.

## Requirements
- Minimal dependencies beyond launchd and a lightweight wrapper script.
- Watch the configured media directories and react to any filesystem change (new files, renames, modifications).
- Observe a configurable “quiet window” (e.g., 60–120 s) after the most recent change before invoking `mediacleanup`.
- Prevent concurrent timer instances so duplicate events don’t spawn multiple wrappers.

## Proposed solution
1. Create a LaunchAgent plist that watches the media paths (using `WatchPaths`/`QueueDirectories`) and launches a wrapper script on each change event.
2. The wrapper acquires an exclusive lock (e.g., `flock` on `/tmp/mediacleanup-debounce.lock`) on startup; if it cannot acquire the lock it updates the “last event” timestamp and exits immediately.
3. The owning wrapper writes the current timestamp to a shared state file and enters a loop that sleeps for the quiet window; during each loop iteration it checks the state file’s mtime (or the timestamp value) and resets the timer if the file has been touched by another invocation.
4. Once the quiet window expires with no new updates, the wrapper releases the lock, removes the state file, and executes `mediacleanup`.
5. The quiet-window length should be configurable so very quiet directories can use a shorter delay while noisy ones get a longer debounce.

## Risks and mitigations
- **Long syncs keeping events alive**: the timer only fires after the quiet window, so as long as the sync client is still touching files the wrapper continues waiting. If an endless stream of tiny updates is expected, consider tuning the window or adding a cap later.
- **State file corruption**: keep writes atomic (write to tmp file then `mv`) and ensure the lock is always released via trap/`finally` logic in the wrapper.

## Next steps
1. Prototype the wrapper script so it can read the quiet-window timeout from config, manage the lock/state file, and call `mediacleanup` when ready.
2. Author the LaunchAgent plist that references the wrapper and document how to enable/disable it.
3. Add TODO/agendized work entry and schedule implementation once the wrapper is validated.
