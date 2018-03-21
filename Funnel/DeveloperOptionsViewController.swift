//
//  DeveloperOptionsViewController.swift
//  Funnel
//
//  Created by Jeremy Irvine on 3/17/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit
import TwitterKit
import Alamofire

class DeveloperOptionsViewController: UIViewController {

    @IBAction func resetUserDefaultsPressed(_ sender: Any) {
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            print("removing \(key)...")
            UserDefaults.standard.removeObject(forKey: key)
        }
        let alert = UIAlertController(title: "Success", message: "UserDefaults.standard have been reset!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func resetSetupComplete(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "setup_complete")
        let u = UserDefaults.standard.string(forKey: "login_username")
        let k = UserDefaults.standard.string(forKey: "login_key")
        print("https://bamboo-us.com/ProjectFeed/reset_stat.php?v=setup_complete&u=\(UserDefaults.standard.string(forKey: "login_username")!)&k=\(UserDefaults.standard.string(forKey: "login_key")!)")
        Alamofire.request("https://bamboo-us.com/ProjectFeed/reset_stat.php?v=setup_complete&u=\(UserDefaults.standard.string(forKey: "login_username")!)&k=\(UserDefaults.standard.string(forKey: "login_key")!)").validate().responseJSON { res in
            switch res.result {
                case .failure(let err):
                    let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    break
                case .success:
                    let alert = UIAlertController(title: "Success", message: "setup_complete has been reset!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
            }
        }
    }
    @IBAction func resetTwitterSessionPressed(_ sender: Any) {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            TWTRTwitter.sharedInstance().sessionStore.logOutUserID(userID)
            let alert = UIAlertController(title: "Success", message: "TWTRTwitterSession.sharedInstance().sessionStore has been reset!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
