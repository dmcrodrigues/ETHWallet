import Foundation
import web3

#if DEBUG
public var Current = World()
#else
public let Current = World()
#endif


public struct World {
    public var storage: EthereumKeyStorage
    public var ethClient: EthereumClient
    public var services: Services

  init(
    network: Network = .ropstenTestnet
  ) {

    guard let storage = EthereumKeyStorage()
        else { fatalError("Unexpected failure while initialising storage") }

    self.storage = storage
    self.ethClient = EthereumClient(url: network.url)
    self.services = Services(
        wallet: WalletService(client: ethClient),
        erc20: ERC20Service(client: ethClient),
        transfer: TransferService(client: ethClient)
    )
  }
}

extension World {
    public struct Services {
        public var wallet: WalletServiceProtocol
        public var erc20: ERC20ServiceProtocol
        public var transfer: TransferServiceProtocol
    }
}
