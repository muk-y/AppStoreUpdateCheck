struct AppStoreUpdateChecker {
    
    func checkUpdate(of version: String, with appStoreVersion: String) -> (updateAvailable: Bool, haveToForceUpdate: Bool) {
        var currentVersionArray = version.components(separatedBy: ".")
        if version.components(separatedBy: ".").count < 3 {
            currentVersionArray.append("0")
        }
        var appStoreVersionArray = appStoreVersion.components(separatedBy: ".")
        if appStoreVersion.components(separatedBy: ".").count < 3 {
            appStoreVersionArray.append("0")
        }
        var forceUpdate = false
        var updateAvailable = false
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
            if let majorCurrentVersion = version.components(separatedBy: ".").first,
               let majorAppStoreVersion = appStoreVersion.components(separatedBy: ".").first {
                forceUpdate = majorCurrentVersion != majorAppStoreVersion
            }
            
            if let minorCurrentVersion = version.components(separatedBy: ".").element(at: 1),
               let minorAppStoreVersion = appStoreVersion.components(separatedBy: ".").element(at: 1) {
                if !forceUpdate {
                    forceUpdate = minorCurrentVersion != minorAppStoreVersion
                }
            }
        }
        return (updateAvailable, forceUpdate)
    }
    
}
