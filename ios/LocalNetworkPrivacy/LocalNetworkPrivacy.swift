//
//  LocalNetworkPrivacy.swift
//  CloudVoiceExpress
//
//  Created by Geraint White on 29/04/2022.
//

import Foundation
import UIKit

@objc public enum OptionalBool: Int {
    case none
    case yes
    case no
}

@objc open class LocalNetworkPrivacy : NSObject {
    let service: NetService

    var completion: ((Bool) -> Void)?
    var timer: Timer?
    var publishing = false

    static var granted: OptionalBool = OptionalBool.none

    @objc public override init() {
        service = .init(domain: "local.", type:"_lnp._tcp.", name: "LocalNetworkPrivacy", port: 1100)
        super.init()
    }

    @objc public static
    func authorizationStatus() -> OptionalBool {
        return LocalNetworkPrivacy.granted
    }

    @objc public
    func checkAccessState(completion: @escaping (Bool) -> Void) {
        self.completion = completion

        timer = .scheduledTimer(withTimeInterval: 2, repeats: true, block: { timer in
            guard UIApplication.shared.applicationState == .active else {
                return
            }

            if self.publishing {
                LocalNetworkPrivacy.granted = OptionalBool.no
                self.timer?.invalidate()
                self.completion?(false)
            }
            else {
                self.publishing = true
                self.service.delegate = self
                self.service.publish()

            }
        })
    }

    deinit {
        service.stop()
    }
}

extension LocalNetworkPrivacy : NetServiceDelegate {
    public func netServiceDidPublish(_ sender: NetService) {
        LocalNetworkPrivacy.granted = OptionalBool.yes
        timer?.invalidate()
        completion?(true)
    }
}
