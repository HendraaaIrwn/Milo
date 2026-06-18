//
//  MiloAgentDetectorProtocol.swift
//  Milo
//

import Foundation

protocol MiloAgentDetectorProtocol {
    var agentType: MiloAgentType { get }

    func detect(
        from processes: [MiloAgentProcessSnapshot],
        previous event: MiloAgentEvent?
    ) -> MiloAgentEvent?
}
