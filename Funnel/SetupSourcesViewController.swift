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
    var socialMediaData: [String] = ["r/ProgrammerHumor"]
    
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
            print("Removing \"\(self.defaults[sender.tag][0])\"")
            defaults.remove(at: sender.tag)
            DispatchQueue.main.async {
                self.rssTable.reloadData()
                self.needsReload = true
            }
    }
    
    
    @objc func handleAdd(sender: UIButton) {
            print("Adding \"\(self.rssSorted[sender.tag][0])\"...")
            defaults.append(self.rssSorted[sender.tag])
            sender.titleLabel?.text = ""
            DispatchQueue.main.async {
                    self.rssTable.reloadData()
            }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(mode == "rss") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "rssCell", for: indexPath) as! AddSourceTableViewCell
            cell.instagramBtn.isHidden = true
            cell.twitterBtn.isHidden = true
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
                    print("\(defaults.joined()) -> \(rssSorted[indexPath.row][0]) (\(indexPath.row)")
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
            cell.lbl.text = ""
            cell.btn.isHidden = true
        } else {
            cell.instagramBtn.isHidden = true
            cell.twitterBtn.isHidden = true
            cell.lbl?.text = socialMediaData[indexPath.row - 1]
            cell.btn.setBackgroundImage(UIImage(named: "ic_remove_circle_48pt_3x"), for: .normal)
            cell.btn.isHidden = false
        }
        
        cell.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 0.82)
        cell.lbl?.backgroundColor = UIColor.clear
        cell.detailTextLabel?.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        return cell
    }
    @objc func textFieldDidChange(textField: UITextField) {
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(mode == "rss") {
            return loadDefaults ? defaults.count : rssSorted.count
        }
        
        // Social Media View
        print(socialMediaData.count + 1)
        return loadDefaults ? socialMediaData.count + 1 : 0
    }
    
    override func viewDidLoad() {
        searchRssField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        rssTable.frame.size.height = getTableSizeForRSS()
        rssTable.dataSource = self
        rssTable.delegate = self
        backBtn.isHidden = true
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
            let r1 = CGFloat((self.socialMediaData.count + 1) * tableHeight)
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
