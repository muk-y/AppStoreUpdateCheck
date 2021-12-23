//
//  AppStoreUpdateCheckAPI.swift
//  
//
//  Created by Mukesh Shakya on 23/12/2021.
//

import Foundation

public protocol AppStoreUpdateCheckAPI {
    
    func checkForUpdate(success: @escaping ((appVersion: String?, isUpdateAvailable: Bool, haveToForceUpdate: Bool, appStoreURL: String?)) -> (), failure: @escaping (Error) -> ())
    
}

public extension AppStoreUpdateCheckAPI {
    
    func checkForUpdate(success: @escaping ((appVersion: String?, isUpdateAvailable: Bool, haveToForceUpdate: Bool, appStoreURL: String?)) -> (), failure: @escaping (Error) -> ()) {
        if Reachability.isConnectedToNetwork {
            guard let bundleInfo = Bundle.main.infoDictionary,
                  let currentVersion = bundleInfo["CFBundleShortVersionString"] as? String,
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
                                  let appStoreVersion = result["version"] as? String,
                                  let appStoreUrl = (result["trackViewUrl"] as? String)?.components(separatedBy: "?").first
                            else {
                                DispatchQueue.main.async {
                                    failure(NSError(domain: "no_such_app", code: 22, userInfo: [NSLocalizedDescriptionKey: "App not found on the app store."]))
                                }
                                return
                            }
                            let updateChecker = AppStoreUpdateChecker()
                            let updateTuple = updateChecker.checkUpdate(of: currentVersion, with: appStoreVersion)
                            DispatchQueue.main.async {
                                success((appVersion: appStoreVersion, isUpdateAvailable: updateTuple.updateAvailable, haveToForceUpdate: updateTuple.haveToForceUpdate, appStoreURL: appStoreUrl))
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
