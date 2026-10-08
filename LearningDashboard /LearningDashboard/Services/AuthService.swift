import Foundation
import Security

enum AuthError: LocalizedError {
    case invalidCredentials
    var errorDescription: String? { "Incorrect email or password." }
}

//Any valid credentials work, except the password "wrongpass".
struct AuthService {
    func login(email: String, password: String) async throws -> String {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return "token-\(UUID().uuidString)"
    }
}

// auth token is stored in the Keychain.
enum TokenStorage {
    private static let account = "authToken"

    private static var query: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrAccount as String: account]
    }

    static func save(_ token: String) {
        SecItemDelete(query as CFDictionary)
        var item = query
        item[kSecValueData as String] = Data(token.utf8)
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(item as CFDictionary, nil)
    }

    static func read() -> String? {
        var request = query
        request[kSecReturnData as String] = true
        var result: AnyObject?
        guard SecItemCopyMatching(request as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete() { SecItemDelete(query as CFDictionary) }
}
