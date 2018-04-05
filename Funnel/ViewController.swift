//
//  ViewController.swift
//  Funnel
//
//  Created by Jeremy Irvine on 2/1/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit
import Alamofire
import TwitterKit
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate {
    
    // Global Variables
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var signupView: UIView!
    var currentInterface = "mainView"
    
    @IBOutlet weak var splash: UILabel!
    @IBOutlet weak var copyright: UILabel!
    
    // Sign In View Variables
    @IBOutlet weak var signinEmail: UITextField!
    @IBOutlet weak var signinPassword: UITextField!
    @IBOutlet weak var signinBtn: UIButton!
    @IBOutlet weak var signinLoadingView: UIActivityIndicatorView!
    
    // Sign Up View Variables
    @IBOutlet weak var signupPasswordField: UITextField!
    @IBOutlet weak var signupEmailField: UITextField!
    @IBOutlet weak var signupNameField: UITextField!
    @IBOutlet weak var agreementsCheckbox: UIButton!
    var agreementsCheckboxEnabled: Bool = true
    let agreementsChecked = UIImage(named: "Checkmark")
    let agreementsUnChecked = UIImage(named: "UnCheckmark")
    
    let animSpeed = 0.3 // Speed of login and signup button transitions
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func convertJson(json: String) -> [[String]] {
        let str = json.replacingOccurrences(of: "'", with: "\"")
        let dataToConvert = str.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        var datas: [[String]] = []
        do {
            let json = try JSON(data: dataToConvert!)
            let data = json.arrayObject as! [[String]]
            datas = data
        } catch {
            print(error.localizedDescription)
        }
        return datas
    }
    
    func alert(msg: String, title: String) {
        let refreshAlert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Return Pressed!")
        // Handle Authentication / Verify Credentials
        if(currentInterface == "loginView") {
            self.signinLoadingView.startAnimating()
            UIView.animate(withDuration: animSpeed) {
                self.signinEmail.alpha = 0.5
                self.signinPassword.alpha = 0.5
                self.signinLoadingView.alpha = 1
            }
            let username = signinEmail.text
            let password = signinPassword.text
            Alamofire.request("https://bamboo-us.com/ProjectFeed/login.php?u=\(username!)&p=\(password!)").validate().responseJSON { response in
                switch response.result {
                case .failure(let err):
                    print(err)
                case .success:
                    if let data = response.result.value {
                        print("Got Response!")
                        UIView.animate(withDuration: self.animSpeed) {
                            self.signinEmail.alpha = 1
                            self.signinPassword.alpha = 1
                            self.signinLoadingView.alpha = 0
                        }
                        let JSON = data as! NSDictionary
                        let status = JSON["status"] as! String
                        print(status)
                        if(status == "success") {
                            print("Insta Key: \(JSON["instaKey"])")
                            print("Setup Complete: \(JSON["setup_complete"])")	
                            UserDefaults.standard.set(JSON["setup_complete"], forKey: "setup_complete")
                            UserDefaults.standard.set(JSON["key"], forKey: "login_key")
                            UserDefaults.standard.set(username, forKey: "login_username")
                            UserDefaults.standard.set(self.convertJson(json: JSON["social_media"] as! String), forKey: "social_media")
                            UserDefaults.standard.set(self.convertJson(json: JSON["news_sources"] as! String), forKey: "rss")
                            UserDefaults.standard.set(JSON["email"], forKey: "login_email")
                            UserDefaults.standard.set(JSON["twt_key"], forKey: "twt_key")
                            UserDefaults.standard.synchronize()
                            self.mainView.alpha = 0
                            print("\((JSON["setup_complete"] as! NSString).doubleValue) -> 0.0 = \((JSON["setup_complete"] as! NSString).doubleValue == 0.0)")
                            if (JSON["setup_complete"] as! NSString).doubleValue == 0.0 {
                                self.performSegue(withIdentifier: "mainToSetup", sender: self)
                            } else {
                                self.performSegue(withIdentifier: "menuToMain", sender: self)
                            }
                        } else {
                            self.alert(msg: "The username or password was incorrect...", title: "Error")
                        }
                    }
                }
            }
        } else if (currentInterface == "signupView") {
            Alamofire.request("https://bamboo-us.com/ProjectFeed/signup.php?p=\(self.signupPasswordField.text!.trimmingCharacters(in: .whitespacesAndNewlines))&n=\(self.signupNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines))&u=\(self.signupEmailField.text!.trimmingCharacters(in: .whitespacesAndNewlines))").validate().responseJSON(completionHandler: { response in
                switch response.result {
                case .failure(let err):
                    print(err)
                case .success:
                    if let data = response.result.value {
                        let JSON = data as! NSDictionary
                        let status = JSON["status"] as! String
                        if status == "success" {
                            UserDefaults.standard.set((JSON["key"] as! NSString).doubleValue, forKey: "login_key")
                            UserDefaults.standard.set(self.signupNameField.text, forKey: "login_username")
                            UserDefaults.standard.synchronize()
                            
                            self.performSegue(withIdentifier: "mainToSetup", sender: self)
                        } else if status == "err_user_taken" {
                            self.alert(msg: "That username has already been taken", title: "Error")
                        }
                    }
                }
            })
        }
        return false
    }
    
    @IBAction func signinBackPressed(_ sender: Any) {
        currentInterface = "mainView"
        print("\(self.loginView.frame.width)")
        UIView.animate(withDuration: animSpeed) {
            self.loginView.frame.origin.x += self.loginView.frame.width
            self.mainView.frame.origin.x += self.mainView.frame.width
        }
        self.signinEmail.resignFirstResponder()
        self.signinPassword.resignFirstResponder()
    }
    
    @IBAction func signupPressed(_ sender: Any) {
        currentInterface = "signupView"
        UIView.animate(withDuration: animSpeed) {
            self.mainView.frame.origin.x -= self.mainView.frame.width
            self.signupView.frame.origin.x -= self.signupView.frame.width
        }
        self.signupNameField.becomeFirstResponder()
    }
    @IBAction func signinPressed(_ sender: Any) {
        currentInterface = "loginView"
        print(loginView.frame.origin.x)
        UIView.animate(withDuration: animSpeed) {
            self.loginView.frame.origin.x -= self.loginView.frame.width
            self.mainView.frame.origin.x -= self.mainView.frame.width
        }
        self.signinEmail.becomeFirstResponder()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.splash.isHidden = true
        self.copyright.isHidden = false
        self.mainView.isHidden = false
        self.signupView.isHidden = false
        self.loginView.isHidden = false
        self.signinLoadingView.alpha = 0
        self.mainView.alpha = 1
        self.loginView.alpha = 1
        if(UserDefaults.standard.string(forKey: "login_key") != nil && UserDefaults.standard.string(forKey: "login_key") != "") {
            print("hi")
            if UserDefaults.standard.double(forKey: "setup_complete") == 1.0 {
                self.performSegue(withIdentifier: "menuToMain", sender: self)
            } else {
                self.performSegue(withIdentifier: "mainToSetup", sender: self)
            }
            self.splash.isHidden = false
            self.copyright.isHidden = true
            self.mainView.alpha = 0
            self.loginView.alpha = 0
            self.signupView.alpha = 0
            
        } else {
            self.loginView.frame.origin.x = self.loginView.frame.width
            self.signupView.frame.origin.x = self.signupView.frame.width
            
            signinEmail.delegate = self
            signinPassword.delegate = self
            
            signupPasswordField.delegate = self
            signupEmailField.delegate = self
            signupNameField.delegate = self
            
        }
    }
    @IBAction func signupBackPressed(_ sender: Any) {
        currentInterface = "mainView"
        UIView.animate(withDuration: animSpeed) {
            self.signupView.frame.origin.x += self.signupView.frame.width
            self.mainView.frame.origin.x = 0
            self.loginView.frame.origin.x = self.loginView.frame.width
        }
        signupNameField.resignFirstResponder()
        signupEmailField.resignFirstResponder()
        signupPasswordField.resignFirstResponder()
    }
    @IBAction func agreementsCheckboxPressed(_ sender: Any) {
        if(agreementsCheckboxEnabled) {
            agreementsCheckboxEnabled = false
            agreementsCheckbox.setImage(agreementsUnChecked, for: .normal)
        } else {
            agreementsCheckboxEnabled = true
            agreementsCheckbox.setImage(agreementsChecked, for: .normal)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if(UserDefaults.standard.bool(forKey: "simpleFeed") == nil) {
            UserDefaults.standard.set(false, forKey: "simpleFeed")
        }
    }
}

