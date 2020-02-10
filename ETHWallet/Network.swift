import Foundation

public enum Network {
    case ropstenTestnet

    public var url: URL {
        switch self {
        case .ropstenTestnet:
            return URL(string: "https://ropsten.infura.io/v3/735489d9f846491faae7a31e1862d24b")!
        }
    }
}
