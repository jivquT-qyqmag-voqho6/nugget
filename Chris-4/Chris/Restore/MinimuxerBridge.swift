// minimuxer-bridge.swift
// Swift-friendly wrapper around the minimuxer C library.

import Foundation

enum MuxError: Error, LocalizedError {
    case startFailed(String)
    case notReady

    var errorDescription: String? {
        switch self {
        case .startFailed(let msg): return "Minimuxer failed to start: \(msg)"
        case .notReady:             return "Minimuxer is not ready. Is WireGuard running?"
        }
    }
}

class Minimuxer {
    static let shared = Minimuxer()
    private var isRunning = false
    private init() {}

    /// Start minimuxer with the data from a .mobiledevicepairing file.
    func start(pairingFileData: Data) throws {
        guard !isRunning else { return }

        let result = pairingFileData.withUnsafeBytes { ptr -> Int32 in
            guard let base = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return -1
            }
            return minimuxer_start(base, UInt(pairingFileData.count))
        }

        if result != 0 {
            let errPtr = minimuxer_last_error()
            let errMsg = errPtr.flatMap { String(cString: $0) } ?? "Unknown error (code \(result))"
            throw MuxError.startFailed(errMsg)
        }

        isRunning = true
    }

    /// Returns true when minimuxer has successfully connected to the device.
    var ready: Bool {
        return minimuxer_ready()
    }

    /// Wait until minimuxer is ready, with a timeout.
    func waitUntilReady(timeout: TimeInterval = 10.0) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if ready { return }
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2s
        }
        throw MuxError.notReady
    }

    func stop() {
        guard isRunning else { return }
        minimuxer_stop()
        isRunning = false
    }
}
