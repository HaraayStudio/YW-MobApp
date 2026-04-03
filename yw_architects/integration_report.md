# YW Architects Auth Integration Report

## 1. What Changes Were Made (File-wise)
- **`lib/models/app_models.dart`**
  - Updated the `AppUser` model to include an optional `String? token` field to store the `accessToken` returned from the login APIs.
- **`lib/services/auth_service.dart`**
  - Completely replaced the hardcoded, mock-based authentication code with `http` calls to communicate with the Spring Boot backend.
  - Implemented manual JWT base64-URL decoding to parse email (`sub`), `role`, and token info correctly without fetching heavy third-party Flutter packages.
  - Connected `loginEmployee` to `POST /api/auth/login`.
  - Connected `loginClient` to `POST /api/auth/clientlogin`.
- **`lib/screens/auth_screens.dart`**
  - Replaced the null-checking error handling with a `try-catch` block inside `_handleEmployeeLogin` and `_handleClientLogin`.
  - Allowed error messages (like `401 Unauthorized` responses) from the backend to correctly reflect on the Login UI inside the `_errorMsg` state dynamically without completely breaking the app.
- **`pubspec.yaml`**
  - Added the `http` package as a dependency to allow Flutter services to send requests to the server. 

## 2. New Files Created
*No entirely new files were introduced within the `lib` folder.* The existing components (`auth_screens.dart`, `auth_service.dart`, `app_models.dart`) successfully accommodated the requirements without forcing a change in file structure.

## 3. APIs Integrated
- **`POST /api/auth/login` (Employee login)**: Validates employee email & password, decodes received JWT to populate internal `UserRole`, then successfully provisions access routing them into the internal sections.
- **`POST /api/auth/clientlogin` (Client login)**: Checks client credentials. Since backend gives an `accessToken` returning to clients, it assigns them under a specific temporary Client `AppUser` instance with appropriate limitations, securing a place for feature-specific client expansion.

## 4. How Login Flow Works Now
1. The user picks their tab (Employee vs. Client) on the login segmented control screen and fills in email & password parameters.
2. The user clicks "Sign In".
3. The UI shows a loading state and calls the appropriate `AuthService` method.
4. `AuthService` executes an async `http.post` sending url-encoded form values mirroring backend `@RequestParam` behavior towards `localhost:8080/api/auth/[...]`.
5. Upon successful (200 OK) response: 
   - `AuthService` parses the returned JSON containing `accessToken`.
   - The token is parsed base64 manually inside Dart to fetch embedded metadata.
   - A fully prepared `AppUser` object (storing the active token) is returned directly modifying state to `onLogin`.
6. Upon rejected request (e.g. 401 Unauthorized):
   - The response raw block body is caught and wrapped inside an `Exception` mapping the plain text "Invalid email or password" string thrown straight to the UI.
   - The UI resets loading state, parsing the error string and beautifully showing it to the client.

## 5. Any Assumptions Made
- **Localhost Backend**: We assumed the application is accessing `http://localhost:8080` for interactions, effectively aiming at desktop, iOS simulator, or Web build environments (since Android standard emulator requires an IP variation `10.0.2.2`). Can easily be altered under `AuthService.baseUrl` line 5.
- **Token Handling Memory**: As explicitly suggested, placing `accessToken` internally into `AppUser` temporarily suffices. Long term, installing `flutter_secure_storage` or `shared_preferences` should handle persistent state tokens so users don't have to keep re-authenticating across app boots.
- **Role Mappings**: Added a fallback map matching string responses from Spring Security into local Dart App `UserRole` enums.
- **Client AppUser Creation**: Added a mock client creation parameter inside `loginClient` directly returning `roles: UserRole.admin` (with dummy UI permissions only tied to Dashboard/Projects limits) since a dedicated Client Role hasn't been structurally appended to `UserRole` in `models.dart` beyond the internal employee tier.
