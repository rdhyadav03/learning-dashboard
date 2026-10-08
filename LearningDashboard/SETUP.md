# Run in Xcode

Needs Xcode 16 or later and internet the first time (to download the Realm package).

1. Double-click `LearningDashboard.xcodeproj` and wait for the package to resolve.
2. Choose an iPhone simulator (iOS 16+) and press **Cmd+R**. Tests: **Cmd+U**.
   (A Signing Team is only needed for a real device.)

Login: any valid email and a password of 6+ characters. `wrongpass` shows the login error.

## If something goes wrong
- "No such module 'RealmSwift'": File -> Packages -> Resolve Package Versions, then clean (Shift+Cmd+K) and build.
- Package version error: Project -> Package Dependencies -> realm-swift -> set "Up to Next Major" from the latest release.
- Duplicate Realm class warning in tests: remove RealmSwift from the test target's "Frameworks and Libraries".

## Demo video (2 minutes)
1. Login: submit empty/short password (validation), `wrongpass` (error), then valid credentials.
2. Course list loads -> open a course -> mark a lesson complete -> go back, progress is updated.
3. Turn off Wi-Fi (the Mac's Wi-Fi if using the Simulator), pull to refresh or relaunch: courses still show with the offline banner.

Other states: with Wi-Fi off on a fresh install you get the error state; set `courses.json` to `[]` to see the empty state.
