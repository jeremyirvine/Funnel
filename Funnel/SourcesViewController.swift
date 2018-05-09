//
//  SourcesViewController.swift
//  Funnel
//
//  Created by Jeremy Irvine on 4/18/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit
import Alamofire
import TwitterKit

extension Array {
    func contains<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

extension Notification.Name {
    static let addSourceItem = Notification.Name("addSourceItem")
    static let removeSourceItem = Notification.Name("removeSourceItem")
}

class SourcesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var table_data: [[String]] = []
    var search_data: [[String]] = []
    var rss: [[String]] = []
    var social: [[String]] = []
    var table_time = 0
    var table_f = false
    var rss_search: [[String]] = []
    
    @IBAction func dismissPressed(_ sender: Any) {
        UserDefaults.standard.set(self.social, forKey: "social")
        NotificationCenter.default.post(name: Notification.Name("reloadMainTable"), object: nil)
        self.dismiss(animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableState == "source") {
            return table_data.count
        }
        return search_data.count
    }
    
    func getIndexForObject(search: [[String]], obj: [String]) -> Int {
        for i in 0...search.count - 1 {
            print(search[i], "->", obj)
            if(search[i] == obj) {
                return i
            }
        }
        return -1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func syncDB() {
        if let rssData = try? JSONSerialization.data(withJSONObject: rss, options: JSONSerialization.WritingOptions(rawValue: 0)) {
            if let socialData = try? JSONSerialization.data(withJSONObject: social, options: JSONSerialization.WritingOptions(rawValue: 0)) {
                let rss = String(data: rssData, encoding: .utf8)?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                let social = String(data: socialData, encoding: .utf8)?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                print("http://bamboo-us.com/ProjectFeed/services.php?q=post_rss-social&rss=\(rss!)&social=\(social!)&u=\(UserDefaults.standard.string(forKey: "login_key")!)&nonce=\(UserDefaults.standard.string(forKey: "login_username")!)")
                Alamofire.request("http://bamboo-us.com/ProjectFeed/services.php?q=post_rss-social&rss=\(rss!)&social=\(social!)&u=\(UserDefaults.standard.string(forKey: "login_username")!)&nonce=\(UserDefaults.standard.string(forKey: "login_key")!)").validate().response(completionHandler: { (res) in
                    if let err = res.error {
                        print("ERR:", err.localizedDescription)
                    } else {
                        print("DATA_FETCH_SUCCESS")
                    }
                })
            }
        }
    }
    
    @objc func removeItem(index: Notification) {
        print(self.social)
        let item = index.userInfo!["index"] as! Int
        print("removing \(item)...")
        print(table_data.count)
        if(table_data[item][0] != "rss") {
            let indx = getIndexForObject(search: self.social, obj: table_data[item])
            if(indx != -1) {
                self.social.remove(at: indx)
                print(social)
            } else {
                print("FATAL: getIndexForObject @ removeItem(:index) has returned -1")
            }
            UserDefaults.standard.set(social, forKey: "social_media")
            
            print(UserDefaults.standard.object(forKey: "social_media") as! [[String]])
        } else {
            let indx = getIndexForObject(search: self.rss, obj: [table_data[item][0], table_data[item][2]])
            self.rss.remove(at: indx)
            UserDefaults.standard.set(self.rss, forKey: "rss")
            UserDefaults.standard.synchronize()
        }
        table_data.remove(at: item)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        syncDB()
    }
    
    @objc func addItem(index: Notification) {
        let item = index.userInfo!["index"] as! Int
        if(search_data[item][1] != "rss") {
            table_data.append(search_data[item])
            self.social.append([search_data[item][0], search_data[item][1]])
            var social_override: [[String]] = []
            for i in 0...self.social.count - 1 {
                if(social[i][1] != "rss") {
                    social_override.append([social[i][0], social[i][1]])
                }
            }
            UserDefaults.standard.set(social_override, forKey: "social_media")
            UserDefaults.standard.synchronize()
            print("adding \(item)...")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            syncDB()
        } else {
            let item = index.userInfo!["index"] as! Int
            table_data.append(search_data[item])
            self.rss.append([search_data[item][0], search_data[item][2]])
            var social_override: [[String]] = []
            for i in 0...self.rss.count - 1 {
                if(rss[i][1] != "rss") {
                    social_override.append([rss[i][0], rss[i][1]])
                }
            }
            UserDefaults.standard.set(rss, forKey: "rss")
            UserDefaults.standard.synchronize()
            print("adding \(item)(rss)...")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            syncDB()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MenuSourcesCell = tableView.dequeueReusableCell(withIdentifier: "sourceCell", for: indexPath) as! MenuSourcesCell
        
        if(tableState == "source") {
            cell.txt?.text = table_data[indexPath.row][0]
            cell.img?.image = UIImage(named: table_data[indexPath.row][1] + " icon gray")
            cell.btn.setImage(UIImage(named: "ic_remove_circle_48pt_3x"), for: .normal)
            cell.btn_action = "remove"
            cell.btn_index = indexPath.row
        } else if (tableState == "search") {
            cell.txt?.text = search_data[indexPath.row][0]
            cell.img?.image = UIImage(named: search_data[indexPath.row][1] + " icon gray")
            cell.btn.setImage(UIImage(named: "add_btn"), for: .normal)
            cell.btn_action = "add"
            cell.btn_index = indexPath.row
            var foundItem = false
            for i in 0...table_data.count - 1 {
                print(table_data[i], "->", search_data[indexPath.row])
                if(table_data[i] == search_data[indexPath.row] || table_data[i] == [search_data[indexPath.row][0], search_data[indexPath.row][1]]) {
                    foundItem = true
                    cell.btn_index = i
                }
            }
            if(foundItem) {
                cell.btn.setImage(UIImage(named: "ic_remove_circle_48pt_3x"), for: .normal)
                cell.btn_action = "remove"
            }
        }
        
        return cell
    }
    

    @IBOutlet weak var instBtn: UIButton!
    @IBOutlet weak var fbBtn: UIButton!
    @IBOutlet weak var twtBtn: UIButton!
    @IBOutlet weak var rdBtn: UIButton!
    @IBOutlet weak var rssBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    
    let INSTAGRAM = "inst"
    let FACEBOOK = "fb"
    let TWITTER = "twt"
    let REDDIT = "rd"
    
    var btnPressed: String = "inst"
    var tableState: String = "source"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(addItem(index:)), name: .addSourceItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeItem(index:)), name: .removeSourceItem, object: nil)
        tableView.delegate = self
        tableView.dataSource = self
        
        DispatchQueue.main.async {
            let rssData = UserDefaults.standard.object(forKey: "rss") as! [[String]]
            self.rss = rssData
            for i in 0...rssData.count - 1 {
                self.table_data.append([rssData[i][0], "rss"])
            }
            let socialData = UserDefaults.standard.object(forKey: "social_media") as! [[String]]
            print("DEBUG:", socialData)
            self.social = socialData
            if(socialData.count >= 1) {
                for i in 0...socialData.count - 1 {
                    self.table_data.append([socialData[i][0], socialData[i][1]])
                }
            }
        }
        
        Alamofire.request("https://bamboo-us.com/ProjectFeed/feed_db.php").responseJSON{ response in
            print("Request")
            if let array = response.result.value as? [NSArray] {
                print("Data")
                for a in array {
                    self.rss_search.append([a[0] as! String, a[1] as! String])
                }
            }
        }
        
        
        searchField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        searchField.delegate = self
    }
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        let txt = textField.text
        DispatchQueue.global(qos: .background).async {
            if(txt != "") {
                self.tableState = "search"
                
                switch self.btnPressed {
                case self.TWITTER:
                    self.searchTwitter(str: txt!)
                    break
                case self.FACEBOOK:
                    
                    break
                case self.INSTAGRAM:
                    
                    break
                case self.REDDIT:
                    self.searchReddit(str: txt!)
                    break
                case "rss":
                    self.searchRss(str: txt!)
                    break
                default:
                    print("FATAL: Invalid Button State '" + self.btnPressed + "' @ SourcesViewController")
                    break
                }
                
                DispatchQueue.main.async {
                    
                    self.reloadTable()
                }
            } else {
                self.tableState = "source"
                DispatchQueue.main.async {
                    
                    self.reloadTable()
                }
            }
            
        }
    }
    
    func searchRss(str: String) {
        self.search_data = []
        print(self.rss)
        for t in rss_search {
            if(t[0].lowercased().range(of: str.lowercased()) != nil) {
                self.search_data.append([t[0], "rss", t[1]])
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func searchTwitter(str: String) {
        self.search_data = []
        if let userID = UserDefaults.standard.string(forKey: "twt_key") {
            print("Twitter_Key Exists")
            if let uid = userID as? String {
                let client = TWTRAPIClient(userID: userID)
                // make requests with client
                let statusesShowEndpoint = "https://api.twitter.com/1.1/users/search.json"
                let params = ["q": str]
                var clientError : NSError?
                
                let request = client.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
                
                client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                    if connectionError != nil {
                        print("Error: \(String(describing: connectionError))")
                    }
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [Any]  {
                            print("-- data --")
                            print(json.count)
                            print(json)
                            if(json.count - 1 > 0) {
                                
                                for index in 0...json.count - 1 {
                                    let indexed = json[index] as! [String: Any]
                                    
                                    print("\(String(describing: indexed["screen_name"]))")
                                    self.search_data.append([String(describing: indexed["screen_name"]!), "twitter"])
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                    }
                                }
                                
                            } else if(json.count == 1) {
                                let indexed = json[0] as! [String: Any]
                                print("\(String(describing: indexed["screen_name"]))")
                                self.search_data.append([String(describing: indexed["screen_name"]!), "twitter"])
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    } catch let jsonError as NSError {
                        print("json error: \(jsonError.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func searchReddit(str: String) {
        Alamofire.request("https://bamboo-us.com/ProjectFeed/service_reddit.php?q=\(str)").validate().responseJSON { response in
            switch response.result {
            case .failure(let err):
                print("Data Error: \(err.localizedDescription)")
                break
            case .success:
                self.search_data = []
                print("Searching...")
                if let data = response.result.value as? [String] {
                    if(data.count != 0) {
                        for i in 0...data.count - 1 {
                            self.search_data.append([data[i], "reddit"])
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            print(data[i])
                        }
                    }
                    print("Data Success")
                    print(data)
                }
                break
            }
        }
    }
    
    func searchInstagram(str: String) {
        if let token = UserDefaults.standard.string(forKey: "instaKey") as? String {
            print("Token:", UserDefaults.standard.string(forKey: "instaKey")!)
            Alamofire.request("https://api.instagram.com/v1/users/search?q=\(str)&access_token=\(token)").responseJSON { response in
                print("Response")
                if let data = response.result.value as? [String: Any] {
                    print("Data")
                    print(data)
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
                    }
                }
            }
        } else {
            print("ERROR: Instagram not present, aborting search (SourcesViewController.swift -> searchInstagram(str: String))")
        }
    }
    
    func reloadIcons() {
        instBtn.setImage(UIImage(named: "instagram Source Disabled"), for: .normal)
        fbBtn.setImage(UIImage(named: "facebook Source Disabled"), for: .normal)
        twtBtn.setImage(UIImage(named: "twitter Source Disabled"), for: .normal)
        rdBtn.setImage(UIImage(named: "reddit Source Disabled"), for: .normal)
        rssBtn.setImage(UIImage(named: "rss Source Disabled"), for: .normal)
        
        switch btnPressed {
            case TWITTER:
                twtBtn.setImage(UIImage(named: "twitter Source Enabled"), for: .normal)
                break
            case FACEBOOK:
                fbBtn.setImage(UIImage(named: "facebook Source Enabled"), for: .normal)
                break
            case INSTAGRAM:
                instBtn.setImage(UIImage(named: "instagram Source Enabled"), for: .normal)
                break
            case REDDIT:
                rdBtn.setImage(UIImage(named: "reddit Source Enabled"), for: .normal)
                break
            case "rss":
                rssBtn.setImage(UIImage(named: "rss Source Enabled"), for: .normal)
                break
            default:
                print("FATAL: Invalid Button State '" + btnPressed + "' @ SourcesViewController")
                break
        }
    }

    @IBAction func rssBtnPressed(_ sender: Any) {
        btnPressed = "rss"
        reloadIcons()
    }
    @IBAction func rdBtnPressed(_ sender: Any) {
        btnPressed = REDDIT
        reloadIcons()
    }
    @IBAction func twtBtnPressed(_ sender: Any) {
        btnPressed = TWITTER
        reloadIcons()
    }
    @IBAction func fbBtnPressed(_ sender: Any) {
        btnPressed = FACEBOOK
        reloadIcons()
    }
    @IBAction func instBtnPressed(_ sender: Any) {
        btnPressed = INSTAGRAM
        reloadIcons()
    }
}
