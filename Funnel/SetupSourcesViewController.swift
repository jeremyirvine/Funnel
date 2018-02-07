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
    @IBOutlet weak var addSourcesTopView: UIView!
    @IBOutlet weak var rssTable: UITableView!
    @IBOutlet weak var searchRssField: UITextField!
    let tableHeight = 44
    
    var rssData:[[String]] = [["Verge", "https://theverge.org"], ["Bloomberg", "https://bloomberg.com"]]
    var defaults = [["Bloomberg", "https://bloomberg.com"]]
    var rssSorted: [[String]] = [[]]
    
    var needsReload = true
    
    var loadDefaults = true
    
    @objc func handleRemove(sender: UIButton) {
            print("Removing \"\(self.defaults[sender.tag][0])\"")
            defaults.remove(at: sender.tag)
            DispatchQueue.main.async {
                self.rssTable.reloadData()
                self.needsReload = true
                self.rssTable.frame.size.height = self.getTableSize()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "rssCell", for: indexPath) as! AddSourceTableViewCell
        cell.btn.tag = indexPath.row
        if(loadDefaults) {
            cell.lbl?.text = "\(defaults[indexPath.row][0]) [Installed]"
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
//                    cell.btn.setTitle("Remove", for: .normal)
                    
                    cell.btn.setBackgroundImage(UIImage(named: "ic_remove_circle_48pt_3x"), for: .normal)
                } else {
//                    cell.btn.setTitle("Add", for: .normal)
                    print("Add")
                    cell.btn.setBackgroundImage(UIImage(named: "add_btn"), for: .normal)
                }
            }
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
            rssTable.frame.size.height = getTableSize()
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
                rssSorted = [["No News Sources Found...", "nourl"]]
            }
            
            rssTable.frame.size.height = getTableSize()
            rssTable.reloadData()
            needsReload = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadDefaults ? defaults.count : rssSorted.count
    }
    
    override func viewDidLoad() {
        searchRssField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        rssTable.frame.size.height = getTableSize()
        rssTable.dataSource = self
        rssTable.delegate = self
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
    
    func getTableSize() -> CGFloat {
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
}
