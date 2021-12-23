//
//  ViewController.swift
//  Example
//
//  Created by ekmacmini43 on 23/12/2021.
//

import UIKit
import AppStoreUpdateCheck

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        checkForUpdate { [weak self] updateTuple in
            self?.showAlert(title: "Success", description: """
                App version: \(updateTuple.appVersion ?? "N/A")\n
                Update available: \(updateTuple.isUpdateAvailable)\n
                Have to force update: \(updateTuple.haveToForceUpdate)\n
                App store url: \(updateTuple.appStoreURL ?? "N/A")\n
                """)
        } failure: { [weak self] error in
            self?.showAlert(title: "Error", description: error.localizedDescription)
        }
    }
    
    private func showAlert(title: String? = nil, description: String) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }


}

//MARK: AppStoreUpdateCheckApi
extension ViewController: AppStoreUpdateCheckAPI {}

