# Learning Dashboard (iOS, Swift + SwiftUI + Realm)

Login -> Course Dashboard -> Course Details, with offline support. iOS 16+, and Realm as a third-party library.

## 1. Architecture
I used MVVM with a Repository:
`View -> ViewModel -> CourseRepository -> CourseService (API) + CourseStore (Realm)`

- Views only show the state. ViewModels hold the state (`loading / loaded / empty / failed`).
- The repository talks to both the API and Realm, so the "try API first, use saved data if it fails" logic is in one place.
- Realm is wrapped in CourseStore. The UI uses plain Course structs, because Realm objects can't be shared across threads easily.
- The API is behind a protocol, so tests can use a fake service.
- Progress is calculated from the lessons, so it is always correct.

## 2. Offline Support
After each successful fetch, courses and lessons are saved in Realm. If the fetch fails, the saved courses are shown with an "offline" banner. If nothing is saved yet, the error screen is shown. When refreshing, lessons the user already completed are kept, so progress is not lost.

## 3. Security
Store the token in the Keychain, not in UserDefaults or Realm. In production I would use an access token and a refresh token, delete them and the cached data on logout, and add certificate pinning. If the cached data is sensitive, I would encrypt the Realm file and keep the key in the Keychain.

## 4. Scale (1M users, hundreds of courses)
1. Add pagination to the course API and fetch only updated courses.
2. Do Realm writes in the background, not on the main thread.
3. Save lesson completions locally and sync them to the server later, with retry.
4. Use a CDN and caching for course content and images.
5. Add crash reporting, analytics, and feature flags.

## 5. Second Platform (Android)
Kotlin + Jetpack Compose with the same layers: ViewModel with `StateFlow`, Repository, Retrofit for the API, Room instead of Realm, Hilt for dependency injection, and the token in encrypted storage (Keystore). WorkManager for background sync, and JUnit tests with a fake API.

## Simplifications
Login and API are mocked (JSON file in the app). The API only returns a lesson count, so the lessons are generated from it. On refresh, local progress wins over server data because there is no real sync.
