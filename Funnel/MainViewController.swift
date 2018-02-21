//
//  MainViewController.swift
//  Funnel
//
//  Created by Jeremy Irvine on 2/3/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBAction func resetDefaultsPressed(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "login_key")
        UserDefaults.standard.removeObject(forKey: "login_username")
        UserDefaults.standard.removeObject(forKey: "social_media")
        UserDefaults.standard.removeObject(forKey: "rss")
        UserDefaults.standard.removeObject(forKey: "instaKey")
        UserDefaults.standard.synchronize()
        let uac = UIAlertController(title: "Debug", message: "NSUserDefaults Cleared!", preferredStyle: .alert)
        self.present(uac, animated: true, completion: nil)
    }
    @IBOutlet weak var backgroundView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        backgroundView.image = UIImage(named: "TopBar")
    }
}
