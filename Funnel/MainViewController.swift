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
        UserDefaults.standard.synchronize()
        var uac = UIAlertController(title: "Debug", message: "NSUserDefaults Keys and Usernames Cleared!", preferredStyle: .alert)
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
