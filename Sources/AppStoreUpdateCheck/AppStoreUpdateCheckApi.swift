//
//  AppStoreUpdateCheckAPI.swift
//  
//
//  Created by Mukesh Shakya on 23/12/2021.
//

import Foundation

protocol AppStoreUpdateCheckAPI {
    
    func checkForUpdate(success: @escaping ((appVersion: String?, isUpdateAvailable: Bool, haveToForceUpdate: Bool, appStoreURL: String?)) -> (), failure: @escaping (Error) -> ())
    
}

extension AppStoreUpdateCheckAPI {
    
    func checkForUpdate(success: @escaping ((appVersion: String?, isUpdateAvailable: Bool, haveToForceUpdate: Bool, appStoreURL: String?)) -> (), failure: @escaping (Error) -> ()) {
        
        if Reachability.isConnectedToNetwork {
            guard let bundleInfo = Bundle.main.infoDictionary,
                  var currentVersion = bundleInfo["CFBundleShortVersionString"] as? String,
                  let identifier = Bundle.main.bundleIdentifier,
                  let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)")
            else {
                DispatchQueue.main.async {
                    success((nil, false, false, nil))
                }
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { (data, resopnse, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        failure(error)
                    }
                } else {
                    do {
                        if let data = data {
                            guard let responseJson = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any],
                                  let result = (responseJson["results"] as? [Any])?.first as? [String: Any],
                                  var appStoreVersion = result["version"] as? String,
                                  let appStoreUrl = (result["trackViewUrl"] as? String)?.components(separatedBy: "?").first
                            else {
                                DispatchQueue.main.async {
                                    // success((false, false, "www.google.com"))
                                    success((nil, false, false, nil))
                                }
                                return
                            }
                            
                            var currentVersionArray = currentVersion.components(separatedBy: ".")
                            if currentVersion.components(separatedBy: ".").count < 3 {
                                currentVersion += ".0"
                                currentVersionArray.append("0")
                            }
                            
                            var appStoreVersionArray = appStoreVersion.components(separatedBy: ".")
                            if appStoreVersion.components(separatedBy: ".").count < 3 {
                                appStoreVersion += ".0"
                                appStoreVersionArray.append("0")
                            }
                            
                            var forceUpdate = false
                            var updateAvailable = false
                            
                            /// old logic
//                            if let currentVersionNumber = Int(currentVersion.replacingOccurrences(of: ".", with: "")),
//                               let appStoreVersionNumber = Int(appStoreVersion.replacingOccurrences(of: ".", with: "")),
//                               appStoreVersionNumber > currentVersionNumber {
//                                updateAvailable = true
//
//                                if let majorCurrentVersion = currentVersion.components(separatedBy: ".").first,
//                                   let majorAppStoreVersion = appStoreVersion.components(separatedBy: ".").first {
//                                    forceUpdate = majorCurrentVersion != majorAppStoreVersion
//                                }
//
//                                if let minorCurrentVersion = currentVersion.components(separatedBy: ".").element(at: 1),
//                                   let minorAppStoreVersion = appStoreVersion.components(separatedBy: ".").element(at: 1) {
//                                    if !forceUpdate {
//                                        forceUpdate = minorCurrentVersion != minorAppStoreVersion
//                                    }
//                                }
//                            }
                            
                            /// new logic
                            appStoreVersionArray.enumerated().forEach({
                                let appStoreVersionDigit = Int($0.element) ?? .zero
                                let currentVersionDigit = Int(currentVersionArray.element(at: $0.offset) ?? "") ?? .zero
                                
                                if !updateAvailable {
                                    if $0.offset == appStoreVersionArray.count - 1 {
                                        let majorAppStoreVersion = Int(appStoreVersionArray.element(at: .zero) ?? "") ?? .zero
                                        let majorCurrentVersion = Int(currentVersionArray.element(at: .zero) ?? "") ?? .zero
                                        
                                        let minorAppStoreVersion = Int(appStoreVersionArray.element(at: 1) ?? "") ?? .zero
                                        let minorCurrentVersion = Int(currentVersionArray.element(at: 1) ?? "") ?? .zero
                                        
                                        if majorAppStoreVersion == majorCurrentVersion && minorAppStoreVersion == minorCurrentVersion {
                                            updateAvailable = appStoreVersionDigit > currentVersionDigit
                                        }
                                        return
                                    }
                                    updateAvailable = appStoreVersionDigit > currentVersionDigit
                                }
                            })
                            
                            if updateAvailable {
                                if let majorCurrentVersion = currentVersion.components(separatedBy: ".").first,
                                   let majorAppStoreVersion = appStoreVersion.components(separatedBy: ".").first {
                                    forceUpdate = majorCurrentVersion != majorAppStoreVersion
                                }
                                
                                if let minorCurrentVersion = currentVersion.components(separatedBy: ".").element(at: 1),
                                   let minorAppStoreVersion = appStoreVersion.components(separatedBy: ".").element(at: 1) {
                                    if !forceUpdate {
                                        forceUpdate = minorCurrentVersion != minorAppStoreVersion
                                    }
                                }
                            }
                            
                            DispatchQueue.main.async {
                                success((appVersion: appStoreVersion, isUpdateAvailable: updateAvailable, haveToForceUpdate: forceUpdate, appStoreURL: appStoreUrl))
                            }
                            
                        } else {
                            DispatchQueue.main.async {
                                success((nil, false, false, nil))
                            }
                        }
                    }
                    catch {
                        DispatchQueue.main.async {
                            success((nil, false, false, nil))
                        }
                    }
                }
            }
            task.resume()
        } else {
            failure(NSError(domain: "no_internet", code: 22, userInfo: [NSLocalizedDescriptionKey: "No internet connection."]))
        }
    }
    
}
