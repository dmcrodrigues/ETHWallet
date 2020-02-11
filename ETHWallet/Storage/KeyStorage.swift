import Foundation
import web3
import Valet

public final class EthereumKeyStorage: EthereumKeyStorageProtocol {
    private let valet: Valet

    private static let privateKeyKeystone: String = "PrivateKeyKeystone"

    init?() {
        guard
            let identifierForVendor = UIDevice.current.identifierForVendor,
            let identifier = Identifier(nonEmpty: "EthereumKeyStorage-\(identifierForVendor)")
            else { return nil }
        
        self.valet = Valet.valet(with: identifier, accessibility: .whenUnlockedThisDeviceOnly)
    }

    public func storePrivateKey(key: Data) throws -> Void {
        self.valet.set(object: key, forKey: Self.privateKeyKeystone)
    }

    public func loadPrivateKey() throws -> Data {
        guard let key = self.valet.object(forKey: Self.privateKeyKeystone)
            else { throw StorageError.unavaiable }

        return key
    }

    enum StorageError: Error {
        case unavaiable
    }
}
