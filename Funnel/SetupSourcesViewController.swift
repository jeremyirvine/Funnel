//
//  SetupSources.swift
//  Funnel
//
//  Created by Jeremy Irvine on 2/2/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

// Use http://beautifytools.com/html-to-json-converter.php

import UIKit
import Alamofire
import TwitterKit
import SwiftyJSON
import SafariServices


class SetupSourcesViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addSourcesTopView: UIView!
    @IBOutlet weak var rssTable: UITableView!
    @IBOutlet weak var searchRssField: UITextField!
    @IBOutlet weak var backBtn: UIButton!
    
    var sfvc: SFSafariViewController = SFSafariViewController(url: URL(string: "https://google.com")!)
    
    let tableHeight = 44
    
    var rssData:[[String]] = []
    var defaults: [[String]] = []
    var rssSorted: [[String]] = [[]]
    var socialMediaData: [[String]] = []
    var socialMediaSort: [String] = []
    var specialIDList: [String] = []
    
    var needsReload = true
    var loadDefaults = true
    var mode = "rss"
    var socialMediaMode = "instagram"
    let fb_access_token = "1885818195082007|ml3-08MDaLy3ZfUqUh4THDg99Wo".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    
    func alert(msg: String, title: String) {
        let refreshAlert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func displayLoading() -> UIAlertController {
        let pending = UIAlertController(title: "Saving Settings...", message: nil, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: pending.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pending.view.addSubview(indicator)
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        
        self.present(pending, animated: true, completion: nil)
        
        return pending
    }
    
    @IBAction func forwardBtnPressed(_ sender: Any) {
        if(mode == "rss") {
            mode = "socialmedia"
            self.backBtn.isHidden = false
            self.titleLbl.text = "Add Social Media Sources"
            DispatchQueue.main.async {
                print("SetSize:", self.getTableSizeForSocialMedia())
                self.rssTable.frame.size.height = self.getTableSizeForSocialMedia()
                self.rssTable.reloadData()
            }
            loadDefaults = true
            self.searchRssField.text = ""
            if(UserDefaults.standard.string(forKey: "instaKey") == nil) {
                let sfvc = SFSafariViewController(url: URL(string: "https://api.instagram.com/oauth/authorize/?client_id=c393eb225cd542d0ab0d2f1e9257f7de&redirect_uri=https://bamboo-us.com/ProjectFeed/token.php&response_type=token")!)
                self.present(sfvc, animated: true, completion: nil)
                self.sfvc = sfvc
            } else {
                let token = UserDefaults.standard.string(forKey: "instaKey")
                print("Got Key:", token)
            }
        } else {
            print("Saving Data...\n \(defaults)")
            let btn = sender as! UIButton
            btn.isEnabled = false
            //            let t = displayLoading()
            if let socialData = try? JSONSerialization.data(withJSONObject: socialMediaData, options: JSONSerialization.WritingOptions(rawValue: 0)) {
                if let rssData = try? JSONSerialization.data(withJSONObject: defaults, options: JSONSerialization.WritingOptions(rawValue: 0)) {
                    let social = String(data: socialData, encoding: .utf8)?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                    let rss = String(data: rssData, encoding: .utf8)?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                    let ud = UserDefaults.standard
                    ud.set(socialMediaData, forKey: "social")
                    ud.set(defaults, forKey: "rss")
                    ud.synchronize()

                    var twt_key = ""
                    if let twt_key_s = ud.string(forKey: "twt_key") {
                        twt_key = twt_key_s
                    }
                    if let twt_key_st = TWTRTwitter.sharedInstance().sessionStore.session()?.authToken {
                        ud.set(twt_key_st, forKey: "twt_key")
                        ud.synchronize()
                        twt_key = twt_key_st
                    }
                    print("https://bamboo-us.com/ProjectFeed/services.php?q=post_rss-social&rss=\(rss!)&social=\(social!)&u=\(ud.string(forKey: "login_username")!)&nonce=\(ud.string(forKey: "login_key")!)&twt_key=\(twt_key)")
                    Alamofire.request("https://bamboo-us.com/ProjectFeed/services.php?q=post_rss-social&rss=\(rss!)&social=\(social!)&u=\(ud.string(forKey: "login_username")!)&nonce=\(ud.string(forKey: "login_key")!)&twt_key=\(twt_key)").validate().responseJSON { response in
                        switch response.result {
                        case .failure(let err):
                            print(err)
                            break
                        case .success:
                            if let data = response.result.value as? [String: String] {
                                if(data["status"] == "success") {
                                    ud.set(1, forKey:"setup_complete")
                                    ud.synchronize()
                                    self.performSegue(withIdentifier: "setupToMain", sender: self)
                                    //                                        t.dismiss(animated: true, completion: nil)
                                } else {
                                    self.alert(msg: "Error", title: "An error occured while trying to submit your data... (ERROR_CODE = \(data["status"]?.uppercased())")
                                    btn.isEnabled = true
                                    //                                        t.dismiss(animated: true, completion: nil)
                                }
                            }
                            break
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        mode = "rss"
        self.backBtn.isHidden = true
        self.titleLbl.text = "Add News Sources (RSS)"
        DispatchQueue.main.async {
            self.rssTable.frame.size.height = self.getTableSizeForRSS()
            self.rssTable.reloadData()
        }
        loadDefaults = true
        self.searchRssField.text = ""
    }
    
    @objc func handleRemove(sender: UIButton) {
        print("Removing")
        if(mode == "rss") {
            print("Removing \"\(self.defaults[sender.tag][0])\"")
            defaults.remove(at: sender.tag)
            DispatchQueue.main.async {
                self.rssTable.reloadData()
                self.rssTable.frame.size.height = self.getTableSizeForRSS()
                self.needsReload = true
            }
        } else {
            print("Removing \"\(self.socialMediaData[sender.tag][0])\"")
            socialMediaData.remove(at: sender.tag)
            DispatchQueue.main.async {
                self.rssTable.reloadData()
                self.rssTable.frame.size.height = self.getTableSizeForSocialMedia()
                self.needsReload = true
            }
        }
    }
    
    
    @objc func handleAdd(sender: UIButton) {
        print("Adding...")
        if(mode == "rss") {
            print("Adding \"\(self.rssSorted[sender.tag][0])\"...")
            defaults.append(self.rssSorted[sender.tag])
            sender.titleLabel?.text = ""
            DispatchQueue.main.async {
                self.rssTable.reloadData()
            }
        } else {
            print("Adding \"\(self.socialMediaSort[sender.tag])\"...")
            print(self.socialMediaSort)
            if(getBtnState() != "facebook" && getBtnState() != "instagram") {
                socialMediaData.append([socialMediaSort[sender.tag], getBtnState()])
            } else {
                socialMediaData.append([socialMediaSort[sender.tag], getBtnState(), specialIDList[sender.tag]])
            }
            sender.titleLabel?.text = ""
            sender.setBackgroundImage(UIImage(named:"ic_remove_circle_48pt_3x"), for: .normal)
            DispatchQueue.main.async {
                self.rssTable.reloadData()
            }
        }
    }
    
    @objc func handleInstagram(sender: UIButton) {
        
    }
    @objc func handleReddit(sender: UIButton) {
        
    }
    @objc func handleFacebook(sender: UIButton) {
        
    }
    @objc func handleTwitter(sender: UIButton) {
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(mode == "rss") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "rssCell", for: indexPath) as! AddSourceTableViewCell
            cell.thumbnailImg.image = UIImage(named: "page icon disabled")
            cell.instagramBtn.isHidden = true
            cell.twitterBtn.isHidden = true
            cell.facebookBtn.isHidden = true
            cell.redditBtn.isHidden = true
            cell.searchImage.isHidden = true
            cell.btn.tag = indexPath.row
            cell.btn.isHidden = false
            if(loadDefaults) {
                cell.lbl?.text = "\(defaults[indexPath.row][0])"
                cell.btn.removeTarget(nil, action: nil, for: .allEvents)
                cell.btn.addTarget(self, action: #selector(handleRemove(sender:)), for: .touchUpInside)
                //            cell.btn.setTitle("Remove", for: .normal)
                cell.btn.setBackgroundImage(UIImage(named: "ic_remove_circle_48pt_3x"), for: .normal)
            } else {
                if(rssSorted.count != 0 && rssSorted[indexPath.row] != []) {
                    cell.lbl?.text = rssSorted[indexPath.row][0]
                    cell.btn.removeTarget(nil, action: nil, for: .allEvents)
                    cell.btn.addTarget(self, action: #selector(handleAdd(sender:)), for: .touchUpInside)
                    //                    print("\(defaults.joined()) -> \(rssSorted[indexPath.row][0]) (\(indexPath.row)")
                    if(defaults.joined().contains(rssSorted[indexPath.row][0])) {
                        cell.btn.setBackgroundImage(UIImage(named: "ic_remove_circle_48pt_3x"), for: .normal)
                        cell.btn.removeTarget(nil, action: nil, for: .allEvents)
                        cell.btn.addTarget(self, action: #selector(handleRemove(sender:)), for: .touchUpInside)
                    } else {
                        if(rssSorted[indexPath.row][1] == "nourl") {
                            cell.btn.isHidden = true
                        } else {
                            cell.btn.setBackgroundImage(UIImage(named: "add_btn"), for: .normal)
                        }
                    }
                }
            }
            
            cell.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 0.82)
            cell.lbl?.backgroundColor = UIColor.clear
            cell.detailTextLabel?.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            
            return cell
        }
        
        // Social Media View
        let cell = tableView.dequeueReusableCell(withIdentifier: "rssCell", for: indexPath) as! AddSourceTableViewCell
        cell.btn.removeTarget(nil, action: nil, for: .allEvents)
        if(indexPath.row == 0) {
            cell.instagramBtn.isHidden = false
            cell.twitterBtn.isHidden = false
            cell.facebookBtn.isHidden = false
            cell.redditBtn.isHidden = false
            cell.searchImage.isHidden = false
            cell.thumbnailImg.isHidden = true
            cell.lbl.text = ""
            cell.btn.isHidden = true
            cell.btn.removeTarget(nil, action: nil, for: .allEvents)
            cell.btn.addTarget(self, action: #selector(handleRemove(sender:)), for: .touchUpInside)
            cell.refreshButtons()
        } else {
            print("Index 1: ", getBtnState())
            cell.instagramBtn.isHidden = true
            cell.twitterBtn.isHidden = true
            cell.facebookBtn.isHidden = true
            cell.redditBtn.isHidden = true
            cell.searchImage.isHidden = true
            cell.thumbnailImg.isHidden = false
            cell.btn.removeTarget(nil, action: nil, for: .allEvents)
            cell.btn.addTarget(self, action: #selector(handleAdd(sender:)), for: .touchUpInside)
            
            cell.btn.tag = indexPath.row - 1
            if(loadDefaults) {
                print("Debug: 1")
                cell.thumbnailImg.image = UIImage(named: "\(socialMediaData[indexPath.row - 1][1]) icon disabled")
                cell.btn.setBackgroundImage(UIImage(named: "ic_remove_circle_48pt_3x"), for: .normal)
                cell.btn.removeTarget(nil, action: nil, for: .allEvents)
                cell.btn.addTarget(self, action: #selector(handleRemove(sender:)), for: .touchUpInside)
                cell.lbl?.text = socialMediaData[indexPath.row - 1][0]
                
            } else {
                print("Current State: \(getBtnState())")
                if(getBtnState() != "facebook" && getBtnState() != "instagram") {
                    print(2)
                    if(socialMediaData.joined().contains(socialMediaSort[indexPath.row - 1])) {
                        cell.btn.setBackgroundImage(UIImage(named: "ic_remove_circle_48pt_3x"), for: .normal)
                        cell.btn.removeTarget(nil, action: nil, for: .allEvents)
                        cell.btn.addTarget(self, action: #selector(handleRemove(sender:)), for: .touchUpInside)
                    } else {
                        
                        cell.btn.setBackgroundImage(UIImage(named: "add_btn"), for: .normal)
                        cell.btn.removeTarget(nil, action: nil, for: .allEvents)
                        cell.btn.addTarget(self, action: #selector(handleAdd(sender:)), for: .touchUpInside)
                    }
                } else {
                    print(3)
                    print(specialIDList)
                    print(socialMediaSort.joined())
                    if(socialMediaData.joined().contains(specialIDList[indexPath.row - 1])) {
                        print(4)
                        cell.btn.setBackgroundImage(UIImage(named: "ic_remove_circle_48pt_3x"), for: .normal)
                        cell.btn.removeTarget(nil, action: nil, for: .allEvents)
                        cell.btn.addTarget(self, action: #selector(handleRemove(sender:)), for: .touchUpInside)
                    } else {
                        print(5)
                        cell.btn.setBackgroundImage(UIImage(named: "add_btn"), for: .normal)
                        cell.btn.removeTarget(nil, action: nil, for: .allEvents)
                        cell.btn.addTarget(self, action: #selector(handleAdd(sender:)), for: .touchUpInside)
                    }
                }
                cell.thumbnailImg.image = UIImage(named: "\(getBtnState()) icon disabled")
                cell.lbl?.text = socialMediaSort[indexPath.row - 1]
            }
            cell.btn.isHidden = false
        }
        
        cell.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 0.82)
        cell.lbl?.backgroundColor = UIColor.clear
        cell.detailTextLabel?.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        cell.refreshButtons()
        
        return cell
    }
    
    func getBtnState() -> String {
        return UserDefaults.standard.string(forKey: "_tmp_social-btn-state")!
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if(mode == "rss") {
            if(textField.text == "") {
                loadDefaults = true
                rssTable.frame.size.height = getTableSizeForRSS()
                rssTable.reloadData()
                needsReload = true
            } else {
                rssSorted = []
                loadDefaults = false
                for t in rssData {
                    if(t[0].lowercased().range(of: textField.text!.lowercased()) != nil) {
                        rssSorted.append(t)
                    }
                }
                if (rssSorted.count == 0) {
                    rssSorted = [["Couldn't find anything ;(", "nourl"]]
                }
                
                rssTable.frame.size.height = getTableSizeForRSS()
                rssTable.reloadData()
                needsReload = true
            }
        } else {
            //            print("socialmedia search \(UserDefaults.standard.string(forKey: "_tmp_social-btn-state"))")
            if(textField.text == "") {
                loadDefaults = true
                self.rssTable.frame.size.height = self.getTableSizeForSocialMedia()
                self.rssTable.reloadData()
            } else {
                loadDefaults = false
                switch UserDefaults.standard.string(forKey: "_tmp_social-btn-state")! {
                case "instagram":
                    print("Searching Instagram...")
                    if let token = UserDefaults.standard.string(forKey: "instaKey") as? String {
                    print("Token:", UserDefaults.standard.string(forKey: "instaKey")!)
                    Alamofire.request("https://api.instagram.com/v1/users/search?q=\(textField.text!)&access_token=\(token)").responseJSON { response in
                        print("Response")
                        if let data = response.result.value as? [String: Any] {
                            print("Data")
                            if let searchItems = data["data"] as? [Any] {
                                var sa: [String] = []
                                var sid: [String] = []
                                if(searchItems.count >= 1) {
                                    for inc in 0...searchItems.count - 1 {
                                        let iter = searchItems[inc] as! [String: Any]
                                        print(iter["username"])
                                        sa.append(iter["username"] as! String)
                                        sid.append(iter["id"] as! String)
                                    }
                                }
                                self.socialMediaSort = sa
                                self.specialIDList = sid
                                DispatchQueue.main.async {
                                    self.rssTable.reloadData()
                                    self.rssTable.frame.size.height = self.getTableSizeForSocialMedia()
                                }
//                                var sa: [String] = []
//                                var sid: [String] = []
//                                if(searchItems.count != 0) {
//                                    for inc in 0...searchItems.count - 1 {
//                                        print(searchItems[inc]["username"])
//                                        sa.append(searchItems[inc]["username"]!)
//                                        sid.append(searchItems[inc]["id"]!)
//                                    }
//                                }
//                                self.socialMediaSort = sa
//                                self.specialIDList = sid
//                                DispatchQueue.main.async {
//                                    self.rssTable.reloadData()
//                                    self.rssTable.frame.size.height = self.getTableSizeForSocialMedia()
//                                }
                            }
                        }
                    }
                    } else {
                        let sfvc = SFSafariViewController(url: URL(string: "https://api.instagram.com/oauth/authorize/?client_id=c393eb225cd542d0ab0d2f1e9257f7de&redirect_uri=https://bamboo-us.com/ProjectFeed/token.php&response_type=token")!)
                        self.present(sfvc, animated: true, completion: nil)
                        self.sfvc = sfvc
                    }
                case "reddit":
                    print("Searching Reddit...")
                    print(textField.text!)
                    Alamofire.request("https://bamboo-us.com/ProjectFeed/service_reddit.php?q=\(textField.text!)").validate().responseJSON { response in
                        switch response.result {
                        case .failure(let err):
                            print("Data Error: \(err.localizedDescription)")
                            break
                        case .success:
                            print("Searching...")
                            if let data = response.result.value as? [String] {
                                print("Data Success")
                                self.socialMediaSort = data
                                DispatchQueue.main.async {
                                    self.rssTable.reloadData()
                                    self.rssTable.frame.size.height = self.getTableSizeForSocialMedia()
                                }
                            }
                            break
                        }
                    }
                    
                case "twitter":
                    print("Searching Twitter...")
                    if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
                        
                        let client = TWTRAPIClient(userID: userID)
                        // make requests with client
                        let statusesShowEndpoint = "https://api.twitter.com/1.1/users/search.json"
                        let params = ["q": textField.text!]
                        var clientError : NSError?
                        
                        let request = client.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
                        
                        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                            if connectionError != nil {
                                print("Error: \(String(describing: connectionError))")
                            }
                            
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [Any]  {
                                print("-- data --")
                                if(json.count - 1 > 0) {
                                    self.socialMediaSort = []
                                    for index in 0...json.count - 1 {
                                        let indexed = json[index] as! [String: Any]
                                        
                                        print("\(String(describing: indexed["screen_name"]))")
                                        self.socialMediaSort.append(indexed["screen_name"] as! String)
                                    }
                                } else if(json.count == 1) {
                                    let indexed = json[0] as! [String: Any]
                                    
                                    self.socialMediaSort = [indexed["screen_name"] as! String];
                                    
                                }
                                DispatchQueue.main.async {
                                    self.rssTable.reloadData()
                                    self.rssTable.frame.size.height = self.getTableSizeForSocialMedia()
                                }
                            }
                            } catch let jsonError as NSError {
                                print("json error: \(jsonError.localizedDescription)")
                            }
                        }
                    }
                case "facebook":
                    print("Searching Facebook...")
                    let search_q = textField.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                    Alamofire.request("https://graph.facebook.com/search?q=\(String(describing: search_q!))&type=page&access_token=\(String(describing: fb_access_token!))&limit=10").responseJSON { response in
                        if let data = response.result.value as? [String: Any] {
                            if let searchItems = data["data"] as? [[String: String]] {
                                var sa: [String] = []
                                var sid: [String] = []
                                if(searchItems.count != 0) {
                                    for inc in 0...searchItems.count - 1 {
                                        sa.append(searchItems[inc]["name"]!)
                                        sid.append(searchItems[inc]["id"]!)
                                    }
                                }
                                self.socialMediaSort = sa
                                self.specialIDList = sid
                                DispatchQueue.main.async {
                                    self.rssTable.reloadData()
                                    self.rssTable.frame.size.height = self.getTableSizeForSocialMedia()
                                }
                            }
                        }
                    }
                    
                default:
                    print("Error: Button State is invalid (SetupSourcesViewController 487 : 17)")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(mode == "rss") {
            return loadDefaults ? defaults.count : rssSorted.count
        }
        
        // Social Media View
        return loadDefaults ? socialMediaData.count + 1 : socialMediaSort.count + 1
    }
    @objc
    func closeSafari() {
        sfvc.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func viewDidLoad() {
        searchRssField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(SetupSourcesViewController.closeSafari), name: NSNotification.Name(rawValue: "closeSafari"), object: nil)
        searchRssField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        rssTable.frame.size.height = getTableSizeForRSS()
        rssTable.dataSource = self
        rssTable.delegate = self
        backBtn.isHidden = true
        
        UserDefaults.standard.set("instagram", forKey: "_tmp_social-btn-state")
        Alamofire.request("https://bamboo-us.com/ProjectFeed/feed_db.php").responseJSON{ response in
            print("Request")
            if let array = response.result.value as? [NSArray] {
                print("Data")
                for a in array {
                    self.rssData.append([a[0] as! String, a[1] as! String])
                }
            }
        }
    }
    
    func getTableSizeForRSS() -> CGFloat {
        if(!loadDefaults) {
            let r1 = CGFloat(self.rssSorted.count * tableHeight)
            let r2 = self.view.frame.height - self.addSourcesTopView.frame.height
            
            if r1 < r2 { return r1}
            
            return r2
        } else {
            let r1 = CGFloat(self.defaults.count * tableHeight)
            let r2 = self.view.frame.height - self.addSourcesTopView.frame.height
            
            if r1 < r2 { return r1}
            
            return r2
        }
    }
    
    func getTableSizeForSocialMedia() -> CGFloat {
        if(!loadDefaults) {
            let r1 = CGFloat((self.socialMediaSort.count + 1) * tableHeight)
            let r2 = self.view.frame.height - self.addSourcesTopView.frame.height
            
            if r1 < r2 { return r1}
            
            return r2
        } else {
            let r1 = CGFloat((self.socialMediaData.count + 1) * tableHeight)
            let r2 = self.view.frame.height - self.addSourcesTopView.frame.height
            
            if r1 < r2 { return r1}
            
            return r2
        }
    }
}

