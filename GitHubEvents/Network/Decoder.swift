import Foundation
import SplebbosNetworking

extension JSONDecoder {
  static let events = decoderWith(.useDefaultKeys, .secondsSince1970)
}
