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

class SetupSourcesViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addSourcesTopView: UIView!
    @IBOutlet weak var rssTable: UITableView!
    @IBOutlet weak var searchRssField: UITextField!
    @IBOutlet weak var backBtn: UIButton!
    let tableHeight = 44
    
    var rssData:[[String]] = []
    var defaults: [[String]] = []
    var rssSorted: [[String]] = [[]]
    var socialMediaData: [[String]] = []
    var socialMediaSort: [String] = []
    
    var needsReload = true
    var loadDefaults = true
    
    var mode = "rss"
    var socialMediaMode = "instagram"
    
    @IBAction func forwardBtnPressed(_ sender: Any) {
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
            print("Removing \"\(self.defaults[sender.tag][0])\"")
            defaults.remove(at: sender.tag)
            DispatchQueue.main.async {
                self.rssTable.reloadData()
                self.rssTable.frame.size.height = self.getTableSizeForRSS()
                self.needsReload = true
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
            socialMediaData.append([socialMediaSort[sender.tag], getBtnState()])
            sender.titleLabel?.text = ""
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
            cell.btn.addTarget(self, action: #selector(handleRemove(sender:)), for: .touchUpInside)
        } else {
            cell.instagramBtn.isHidden = true
            cell.twitterBtn.isHidden = true
            cell.facebookBtn.isHidden = true
            cell.redditBtn.isHidden = true
            cell.searchImage.isHidden = true
            cell.thumbnailImg.isHidden = false
            cell.btn.addTarget(self, action: #selector(handleAdd(sender:)), for: .touchUpInside)
            
            cell.btn.tag = indexPath.row - 1
            if(loadDefaults) {
                
                cell.thumbnailImg.image = UIImage(named: "\(socialMediaData[indexPath.row - 1][1]) icon disabled")
                cell.btn.setBackgroundImage(UIImage(named: "ic_remove_circle_48pt_3x"), for: .normal)
                cell.lbl?.text = socialMediaData[indexPath.row - 1][0]
            } else {
                
                cell.thumbnailImg.image = UIImage(named: "\(getBtnState()) icon disabled")
                cell.btn.setBackgroundImage(UIImage(named: "add_btn"), for: .normal)
                cell.lbl?.text = socialMediaSort[indexPath.row - 1]
            }
            cell.btn.isHidden = false
        }
        
        cell.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 0.82)
        cell.lbl?.backgroundColor = UIColor.clear
        cell.detailTextLabel?.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
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
                    case "facebook":
                        print("Searching Facebook...")
                default:
                    print("Error: Button State is invalid (SetupSourcesViewController 195 : 17)")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(mode == "rss") {
            return loadDefaults ? defaults.count : rssSorted.count
        }
        
        // Social Media View
        print(socialMediaData.count + 1)
        print("Size: \(loadDefaults ? socialMediaData.count + 1 : 0)")
        return loadDefaults ? socialMediaData.count + 1 : socialMediaSort.count + 1
    }
    
    override func viewDidLoad() {
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
