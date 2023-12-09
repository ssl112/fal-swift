import Dispatch
import Foundation

class CodableRealtimeConnection<Input: Encodable>: RealtimeConnection<Input> {
    override public func send(_ data: Input) throws {
        let jsonData = try JSONEncoder().encode(data)
        guard let json = String(data: jsonData, encoding: .utf8) else {
            throw FalRealtimeError.invalidResult
        }
        try sendReference(.string(json))
    }
}

public extension Realtime {
    func connect<Input: Encodable, Output: Decodable>(
        to app: String,
        connectionKey: String,
        throttleInterval: DispatchTimeInterval,
        onResult completion: @escaping (Result<Output, Error>) -> Void
    ) throws -> RealtimeConnection<Input> {
        handleConnection(
            to: app, connectionKey: connectionKey, throttleInterval: throttleInterval,
            resultConverter: { data in
                let result = try JSONDecoder().decode(Output.self, from: data)
                return result
            },
            connectionFactory: { send, close in
                CodableRealtimeConnection(send, close)
            },
            onResult: completion
        )
    }
}
