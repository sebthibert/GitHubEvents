import SplebbosNetworking

extension Resource {
  static let host = "sebthibert.github.io"
  static let path = "/api/events.json"

  static let load = Resource(
    host: host,
    path: path
  )
  
  static let refresh = Resource(
    host: host,
    path: path,
    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
  )
}
