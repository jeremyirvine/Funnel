//
//  SettingsViewController.swift
//  Funnel
//
//  Created by Jeremy Irvine on 3/14/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var usr_img: UIImageView!
    @IBOutlet weak var usr_name: UILabel!
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        usr_img.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
