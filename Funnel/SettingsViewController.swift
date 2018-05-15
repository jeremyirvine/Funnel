//
//  SettingsViewController.swift
//  Funnel
//
//  Created by Jeremy Irvine on 3/14/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit
import Alamofire

class SettingsViewController: UIViewController {
    @IBOutlet weak var usr_img: UIImageView!
    @IBOutlet weak var usr_email: UILabel!
    @IBOutlet weak var usr_name: UILabel!
    @IBOutlet weak var simpleFeedSwitch: UISwitch!
    @IBAction func backBtnPressed(_ sender: Any) {
        print(simpleFeedSwitch.isOn)
        UserDefaults.standard.set(simpleFeedSwitch.isOn, forKey: "simpleFeed")
        dismiss(animated: true, completion: nil)
    }
    var shouldLogout = false
    
    @IBAction func devOptionsPressed(_ sender: Any) {
        
    }
    @IBAction func editPasswordPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Edit Password", message: "Enter a new password", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Old Password"
            textField.isSecureTextEntry = true
        }
        alert.addTextField { (textField) in
            textField.placeholder = "New Password"
            textField.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let password = alert?.textFields![0]
            let email = alert?.textFields![1]
            print("Password field: \(password?.text)")
            print("Email field: \(email?.text)")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func editEmailPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Edit Email", message: "Enter a new email", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        alert.addTextField { (textField) in
            textField.placeholder = "New Email"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let password = alert?.textFields![0]
            let email = alert?.textFields![1]
            print("Password field: \(password?.text)")
            print("Email field: \(email?.text)")
            let username = UserDefaults.standard.string(forKey: "login_username")
            let nonce = UserDefaults.standard.string(forKey: "login_key")
            let part1: String = "http://bamboo-us.com/ProjectFeed/services.php?q=edit_email&p=" + password!.text!
            let part2: String =  "&u=" + username!
            let part3: String =  "&nonce=" + nonce!
            let part4: String =  "&email=" + email!.text!
            print(part1 + part2 + part3 + part4)
            Alamofire.request(part1 + part2 + part3 + part4).response{  (res) in
                print(String(data: res.data!, encoding: .utf8))
                if(String(data: res.data!, encoding: .utf8) == "success") {
                    UserDefaults.standard.set(email!.text!, forKey: "login_email")
                    self.usr_email.text = email!.text!
                } else {
                    let al = UIAlertController(title: "Error", message: "Incorrect password", preferredStyle: .alert)
                    self.present(al, animated:true, completion: nil)
                }
            }
//            Alamofire.request()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func logoutBtnPressed(_ sender: Any) {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: "login_key")
        ud.removeObject(forKey: "rss")
        ud.removeObject(forKey: "social_media")
        ud.removeObject(forKey: "setup_complete")
        ud.set(true, forKey: "should_logout")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tacBtnPressed(_ sender: Any) {
        // Terms and Conditions
    }
    @IBAction func privacyBtnPressed(_ sender: Any) {
        // Privacy Policy
    }
    @IBAction func legalBtnPressed(_ sender: Any) {
        // Legal Disclosures
    }
    @IBAction func supportBtnPressed(_ sender: Any) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        usr_img.layer.cornerRadius = 10
        shouldLogout = false
        simpleFeedSwitch.setOn(UserDefaults.standard.bool(forKey: "simpleFeed"), animated: false)
        usr_name.text = UserDefaults.standard.string(forKey: "login_username") ?? "John Doe"
        usr_email.text = UserDefaults.standard.string(forKey: "login_email") ?? "johndoe@gmail.com"
    }
    
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
