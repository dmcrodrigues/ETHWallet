import Foundation
import BigInt

extension BigUInt {

    var toEther: Decimal {
        guard let value = Decimal(string: description)
            else { fatalError("Unexpected failure") }

        return value / pow(Decimal(10), 18)
    }
}

extension Decimal {

    var toWei: BigUInt {
        guard let value = BigUInt((self * pow(Decimal(10), 18)).description)
            else { fatalError("Unexpected failure") }

        return value
    }
}
