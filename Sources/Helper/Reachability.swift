//
//  Reachability.swift
//
//  Created by Mukesh Shakya on 23/12/2021.
//

import SystemConfiguration

public class Reachability {
    
    class var isConnectedToNetwork: Bool {
        var zeroAddress = sockaddr_in(sin_len: .zero, sin_family: .zero, sin_port: .zero, sin_addr: in_addr(s_addr: .zero), sin_zero: (.zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: .zero)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != .zero
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != .zero
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
    
}
