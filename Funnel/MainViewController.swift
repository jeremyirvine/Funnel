//
//  MainViewController.swift
//  Funnel
//
//  Created by Jeremy Irvine on 2/3/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit
import TwitterKit
import FeedKit
import SwiftyJSON
import Alamofire
import WebKit

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var slideMenuContainer: UIView!
    @IBOutlet weak var SlideMenuView: UIView!
    @IBOutlet weak var sourcesTable: UITableView!
    @IBOutlet weak var menuFeedBtn: UIButton!
    @IBOutlet weak var menuSourcesBtn: UIButton!
    @IBOutlet weak var menuSettingsBtn: UIButton!
    @IBOutlet weak var showContentView: UIView!
    @IBOutlet weak var funnelTitle: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Minified Show Content View
    @IBOutlet weak var show_sourceName: UILabel!
    @IBOutlet weak var show_backButton: UIButton!
    @IBOutlet weak var show_contentImage: UIImageView!
    @IBOutlet weak var show_sourceImage: UIImageView!
    @IBOutlet weak var show_contentTitle: UILabel!
    @IBOutlet weak var show_contentText: UITextView!
    @IBOutlet weak var show_webView: UIWebView!
    
    var shouldLogout = false
    
    @IBAction func show_backButtonPressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.show_webView.loadHTMLString("", baseURL: nil)
        }
        UIView.animate(withDuration: slideMenuSpeed, animations: {
            self.sourcesTable.frame.origin.x = 0
            self.showContentView.frame.origin.x = self.showContentView.frame.width
            self.funnelTitle.alpha = 1
            self.show_backButton.alpha = 0
        })
    }
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        let src = segue.source
        let dst = segue.destination

        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        },
                       completion: { finished in
                        src.present(dst, animated: false, completion: nil)
        }
        )
    }
    
   
    
    var slideMode = "closed"
    
    let slideMenuSpeed: Double = 0.2
    var blurEffectView: UIVisualEffectView?
    var imageNames: [String: String] = [:]
    
    var sources: [[String]] = []
    let fb_access_token = "1885818195082007|ml3-08MDaLy3ZfUqUh4THDg99Wo".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    
    @IBAction func menuFeedBtnPressed(_ sender: Any) {
    }
    @IBAction func menuSourcesBtnPressed(_ sender: Any) {
    }
    @IBAction func menuSettingsBtnPressed(_ sender: Any) {
        print("Settings")
        performSegue(withIdentifier: "mainToSettings", sender: self)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sources.count
    }
    
    @objc func handleDidTouch(notif: Notification) {
    
        // Schema:
        // 0: Article Title
        // 1: Preview Content
        // 2: Source Thumbnail Url?
        // 3: Article Thumbnail Url?
        // 4: Source Name
        
        self.show_sourceImage.layer.cornerRadius = self.show_contentImage.frame.size.width / 2
        self.show_webView.isHidden = true
        
        if(slideMode == "closed") {
            if(UserDefaults.standard.bool(forKey: "simpleFeed")) {
                
                let id = notif.userInfo!["id"] as! Int
                print(sources[id][1])
                UIView.animate(withDuration: slideMenuSpeed, animations: {
                    self.sourcesTable.frame.origin.x = -self.sourcesTable.frame.width
                    self.show_sourceName.text = self.sources[id][4]
                    self.show_contentTitle.text = self.sources[id][0]
                    self.show_contentText.text = self.sources[id][1]
                    if self.imageNames.contains(where: {$0.key == self.sources[id][3]}) {
                        let imageURL = self.getDocumentsDirectory().appendingPathComponent(self.imageNames[self.sources[id][3]]! + ".png")
                        let image    = UIImage(contentsOfFile: imageURL.path)
                        self.show_contentImage.image = image
                    } else {
                        self.show_contentImage.image  = UIImage(named: "Unkown_Image")
                    }
                    // Set source image
                    switch self.sources[id][2] {
                        case "twitter":
                            self.show_sourceImage.layer.cornerRadius = 0
                            self.show_sourceImage.image = UIImage(named: "twitter icon enabled")
                            self.show_sourceImage.frame.size.width = 25
                            break
                        case "instagram":
                            self.show_sourceImage.layer.cornerRadius = 0
                            self.show_sourceImage.image = UIImage(named: "instagram icon enabled")
                            self.show_sourceImage.frame.size.width = 25
                            break
                        case "reddit":
                            self.show_contentImage.layer.cornerRadius = 0
                            self.show_sourceImage.image = UIImage(named: "reddit icon red")
                            self.show_sourceImage.frame.size.width = 18
                            break
                        case "facebook":
                            self.show_sourceImage.layer.cornerRadius = 0
                            self.show_sourceImage.image = UIImage(named: "facebook icon enabled")
                            self.show_sourceImage.frame.size.width = 25
                            break
                        default:
                            self.show_sourceImage.frame.size.width = 25
                            self.show_sourceImage.layer.cornerRadius = self.show_sourceImage.frame.size.width / 2
                            if self.imageNames.contains(where: {$0.key == self.sources[id][2]}) {
                                let imageURL = self.getDocumentsDirectory().appendingPathComponent(self.imageNames[self.sources[id][2]]! + ".png")
                                let image    = UIImage(contentsOfFile: imageURL.path)
                                self.show_sourceImage.image = image
                            }  else {
                                do {
                                    if let url = URL(string: self.sources[id][2]) {
                                        if let data = try? Data(contentsOf: url) {
                                            if let source = UIImage(data: data) {
                                                self.show_sourceImage.image = source
                                                if let data = UIImagePNGRepresentation(source) {
                                                    let nonce = UUID().uuidString
                                                    self.imageNames[self.sources[id][2]] = nonce
                                                    let filename = self.getDocumentsDirectory().appendingPathComponent(nonce + ".png")
                                                    try? data.write(to: filename)
                                                }
                                            } else {
                                                self.show_sourceImage.image = UIImage(named: "Unkown_Image")
                                            }
                                        } else {
                                            self.show_sourceImage.image = UIImage(named: "Unkown_Image")
                                        }
                                    } else {
                                        self.show_sourceImage.image = UIImage(named: "Unknown_Image")
                                    }
                                    
                                }
                            }
                            break
                    }
                    self.showContentView.frame.origin.x = 0
                    self.funnelTitle.alpha = 0
                    self.show_backButton.alpha = 1
                })
            } else {
                UIView.animate(withDuration: slideMenuSpeed, animations: {
                    let id = notif.userInfo!["id"] as! Int
                    self.show_webView.isHidden = false
                    self.sourcesTable.frame.origin.x = -self.sourcesTable.frame.width
                    self.showContentView.frame.origin.x = 0
                    self.funnelTitle.alpha = 0
                    self.show_backButton.alpha = 1
                    if(self.sources[id][2] == "reddit") {
                        self.show_webView.loadHTMLString("", baseURL: nil)
                        self.show_webView.loadRequest(URLRequest(url: URL(string: self.sources[id][5])!))
                    } else if (self.sources[id][4] == "twitter") {
                        self.show_webView.loadHTMLString("", baseURL: nil)
                        self.show_webView.loadRequest(URLRequest(url: URL(string: self.sources[id][5])!))
                    } else if (self.sources[id][4] == "facebook") {
                        self.show_webView.loadHTMLString("", baseURL: nil)
                        self.show_webView.loadRequest(URLRequest(url: URL(string: self.sources[id][5])!))
                    } else {
                        self.show_webView.loadHTMLString("", baseURL: nil)
                        self.show_webView.loadRequest(URLRequest(url: URL(string: self.sources[id][6])!))
                    }
//                    switch self.sources[id][6] {
//                        case "reddit":
//                            self.show_webView.loadHTMLString("", baseURL: nil)
//                            self.show_webView.loadRequest(URLRequest(url: URL(string: self.sources[id][5])!))
//                            break;
//                        case "twitter":
//                            break
//                        default:
//                            self.show_webView.loadHTMLString("", baseURL: nil)
//                            self.show_webView.loadRequest(URLRequest(url: URL(string: self.sources[id][6])!))
//                            break
//                    }
                })
            }
        } else {
            slideMode = "closed"
            UIView.animate(withDuration: slideMenuSpeed) {
                self.blurEffectView?.frame.origin.x = self.view.frame.width
                self.SlideMenuView.frame.origin.x = self.view.frame.width
                self.slideMenuContainer.frame.origin.x = self.view.frame.width
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected Post:", sources[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            print("Processing Cell...")
            let cell = tableView.dequeueReusableCell(withIdentifier: "sourceCell", for: indexPath) as! SourceListCell
            cell.articlePreview.text = sources[indexPath.row][1]
            cell.articleTitle.text = sources[indexPath.row][0]
            cell.sourceName.text = sources[indexPath.row][4]
            cell.id = indexPath.row
            cell.icon.frame.size.width = 25
            cell.icon.frame.size.height = 25
            if(sources[indexPath.row][4] == "twitter") {
                cell.icon.image = UIImage(named: "twitter icon enabled")
                cell.icon.layer.cornerRadius = 0
                cell.articlePreviewImg.isHidden = true
            } else if(sources[indexPath.row][2] == "reddit") {
                cell.icon.image = UIImage(named: "reddit icon red")
                cell.icon.layer.cornerRadius = 0
                cell.articlePreviewImg.isHidden = false
                if imageNames.contains(where: {$0.key == sources[indexPath.row][3]}) {
                    let imageURL = getDocumentsDirectory().appendingPathComponent(imageNames[sources[indexPath.row][3]]! + ".png")
                    let image    = UIImage(contentsOfFile: imageURL.path)
                    cell.articlePreviewImg.image = image
                } else {
                    cell.articlePreviewImg.image = UIImage(named: "Unkown_Image")
                }
//                    do {
//                        if let url = URL(string: sources[indexPath.row][3]) {
//                            if let data = try? Data(contentsOf: url) {
//                                if let source = UIImage(data: data) {
//                                    cell.articlePreviewImg.image = source
//                                    if let data = UIImagePNGRepresentation(source) {
//                                        let nonce = UUID().uuidString
//                                        imageNames[sources[indexPath.row][3]] = nonce
//                                        let filename = getDocumentsDirectory().appendingPathComponent(nonce + ".png")
//                                        try? data.write(to: filename)
//                                    }
//                                } else {
//                                    cell.articlePreviewImg.image = UIImage(named: "Unkown_Image")
//                                }
//                            } else {
//                                cell.articlePreviewImg.image = UIImage(named: "Unkown_Image")
//                            }
//                        } else {
//                            cell.articlePreviewImg.image = UIImage(named: "Unknown_Image")
//                        }
//
//                    }
//                }
            } else if (sources[indexPath.row][2] == "facebook") {
                cell.icon.image = UIImage(named: "facebook icon enabled")
                cell.articlePreviewImg.isHidden = true
            } else {
                cell.icon.layer.cornerRadius = cell.icon.frame.height / 2
                if imageNames.contains(where: {$0.key == sources[indexPath.row][3]}) {
                    let imageURL = getDocumentsDirectory().appendingPathComponent(imageNames[sources[indexPath.row][3]]! + ".png")
                    let image    = UIImage(contentsOfFile: imageURL.path)
                    cell.articlePreviewImg.image = image
                } else {
                        do {
                            if let url = URL(string: sources[indexPath.row][3]) {
                                if let data = try? Data(contentsOf: url) {
                                    if let source = UIImage(data: data) {
                                        cell.articlePreviewImg.image = source
                                        if let data = UIImagePNGRepresentation(source) {
                                            let nonce = UUID().uuidString
                                            imageNames[sources[indexPath.row][3]] = nonce
                                            let filename = getDocumentsDirectory().appendingPathComponent(nonce + ".png")
                                            try? data.write(to: filename)
                                        }
                                    } else {
                                        cell.articlePreviewImg.image = UIImage(named: "Unkown_Image")
                                    }
                                } else {
                                    cell.articlePreviewImg.image = UIImage(named: "Unkown_Image")
                                }
                            } else {
                                cell.articlePreviewImg.image = UIImage(named: "Unknown_Image")
                            }

                        }
                }

            if imageNames.contains(where: {$0.key == sources[indexPath.row][2]}) {
                let imageURL = getDocumentsDirectory().appendingPathComponent(imageNames[sources[indexPath.row][2]]! + ".png")
                let image    = UIImage(contentsOfFile: imageURL.path)
                cell.icon.image = image
            } else {
                do {
                    if let url = URL(string: sources[indexPath.row][2]) {
                        if let data = try? Data(contentsOf: url) {
                            if let source = UIImage(data: data) {
                                cell.icon.image = source
                                if let data = UIImagePNGRepresentation(source) {
                                    let nonce = UUID().uuidString
                                    imageNames[sources[indexPath.row][2]] = nonce
                                    let filename = getDocumentsDirectory().appendingPathComponent(nonce + ".png")
                                    try? data.write(to: filename)
                                }
                            } else {
                                cell.icon.image = UIImage(named: "Unkown_Image")
                            }
                        } else {
                            cell.icon.image = UIImage(named: "Unkown_Image")
                        }
                    } else {
                        cell.icon.image = UIImage(named: "Unknown_Image")
                    }
                    
                }
            }
        }
        return cell
    }
    
    
    func setSources() {
        let ud = UserDefaults.standard
        let rssData = ud.object(forKey: "rss") as! [[String]]
        let socialData = ud.object(forKey: "social_media") as! [[String]]
        print(rssData.count)
        rssData.forEach { (source) in
            let feedurl = URL(string: source[1])
            print("Searching: \(feedurl!)...")
           
            print("URL:", source[1])
            let parser = FeedParser(URL: feedurl!)
            parser?.parseAsync(result: { (result) in
                print("Success")
                print(result.error?.localizedDescription)
                result.rssFeed?.items?.forEach({ (entry) in
//                    print(entry.)
                    let str = entry.content?.contentEncoded?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "\n", with: "")
                    print(entry.dublinCore?.dcCreator)
                    self.sources.append([entry.title!, str!, (result.rssFeed?.image?.url!) ?? "", "nope", source[0], (entry.pubDate?.toString(dateFormat: "MM-dd-yyy"))!, entry.link!])
//                    DispatchQueue.main.async {
//                        self.sources.sort(by: {$0[0] > $1[0]})
//                        self.sourcesTable.reloadData()
//                    }
                })
                result.atomFeed?.entries?.forEach({ (entry) in
                    let str = entry.content?.value?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "\n", with: "")
                    let date = entry.published
                    self.sources.append([entry.title!, str!, (result.atomFeed?.icon)!, "nope", source[0], (date?.toString(dateFormat: "MM-dd-yyy"))!, (entry.links?.first?.attributes?.href)!])
//                    DispatchQueue.main.async {
//                        self.sources.sort(by: {$0[0] > $1[0]})
//                        self.sourcesTable.reloadData()
//                    }
                })
                result.jsonFeed?.items?.forEach({ (entry) in
                    let str = entry.contentText
                    let date = entry.datePublished
                    self.sources.append([entry.title!, str!, (result.jsonFeed?.icon)!, "nope", source[0], (date?.toString(dateFormat: "MM-dd-yyy"))!, String(describing: entry.url)])
//                    DispatchQueue.main.async {
//                        self.sources.sort(by: {$0[0] > $1[0]})
//                        self.sourcesTable.reloadData()
//                    }
                })
            })
        }
        
        print(socialData)
        socialData.forEach { (source) in
            print(source[0])
            if(source[1] == "twitter") {
                print()
                grabSocial(twtr_id: source[0])
            } else if (source[1] == "reddit") {
                grabSocial(reddit_id: source[0])
            } else if (source[1] == "facebook") {
                grabSocial(facebook_id: source[2])
            }
        }
        sources.sort(by: {$0[0] > $1[0]})
        DispatchQueue.main.async {
            self.sourcesTable.reloadData()
        }
        
        
        // Schema:
        // 0: Article Title
        // 1: Preview Content
        // 2: Source Thumbnail Url?
        // 3: Article Thumbnail Url?
        // 4: Source Name
        // 5 (optional): URL
    }
    func grabSocial(facebook_id: String) {
        print("Getting social for fb-" + facebook_id)
        var url = "https://graph.facebook.com/v2.12/" + facebook_id
        url = url + "?access_token=" + fb_access_token! + "&fields=name,id,posts"
        Alamofire.request(url).responseJSON { (response) in
            if let data = response.result.value {
                let json = JSON(data)
                print(json["posts"]["data"][0])
                for i in 0...json["posts"]["data"].count - 1 {
                    let name = json["name"]
                    let id = json["posts"]["data"][i]["id"]
                    let created_tiem = json["posts"]["data"][i]["created_time"]
                    let message = json["posts"]["data"][i]["message"]
                    self.sources.append([name.string!, message.string!, "facebook", "nope", "facebook"])
                    DispatchQueue.main.async {
                        self.activityIndicator.isHidden = true
//                        self.sourcesTable.reloadData()
                    }
                }
                
            }
        }
    }
    
    func grabSocial(reddit_id: String) {
//        print("Getting social for https://reddit.com/\(reddit_id)/new.json?sort=new")
        let url = "https://reddit.com/\(reddit_id)/new.json?sort=new"
        Alamofire.request(url).responseJSON { response in
            if((response.result.value) != nil) {
                let swiftyJsonVar = JSON(response.result.value!)
//                print(swiftyJsonVar["data"]["children"][0]["data"]["title"])
                let children = swiftyJsonVar["data"]["children"]
                children.forEach({ (arr) in
//                    print(arr.1["data"]["title"])
                    let title = arr.1["data"]["title"].string!
                    let thumbnail = arr.1["data"]["thumbnail"].string!
                    let author = arr.1["data"]["author"].string!
                    self.sources.append([author, title, "reddit", thumbnail, "reddit (" + reddit_id + ")", "https://www.reddit.com" + arr.1["data"]["permalink"].string!])
                    if self.imageNames.contains(where: {$0.key == thumbnail}) {
                        DispatchQueue.main.async {
                            self.activityIndicator.isHidden = true
                            self.sources.sort(by: {$0[0] > $1[0]})
                            self.sourcesTable.reloadData()
                        }
                       return
                    } else {
                        do {
                            if let url = URL(string: thumbnail) {
                                if let data = try? Data(contentsOf: url) {
                                    if let source = UIImage(data: data) {
                                        if let data = UIImagePNGRepresentation(source) {
                                            let nonce = UUID().uuidString
                                            self.imageNames[thumbnail] = nonce
                                            let filename = self.getDocumentsDirectory().appendingPathComponent(nonce + ".png")
                                            try? data.write(to: filename)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.activityIndicator.isHidden = true
                        self.sources.sort(by: {$0[0] > $1[0]})
                        self.sourcesTable.reloadData()
                    }
                })
            }
        }
    }
    
    func grabSocial(twtr_id: String) {
        print("Getting social for \(twtr_id)...")
        if let userID = UserDefaults.standard.string(forKey: "twt_key") {
            print("Got ID: \(TWTRTwitter.sharedInstance().sessionStore.session()?.userID)")
            let client = TWTRAPIClient(userID: userID)
            let parameter : [String : Any] = ["screen_name" : twtr_id , "count" : "10" as AnyObject]
            let req = client.urlRequest(withMethod: "GET", urlString: "https://api.twitter.com/1.1/statuses/user_timeline.json", parameters: parameter, error: nil)
            print("Req_URL: \(req.value(forHTTPHeaderField: "auth_token"))")
            NSURLConnection.sendAsynchronousRequest(req, queue: .main, completionHandler: { (response, data, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
//                    print("Got Social Response: ")
                    SwiftyJSON.JSON(data).forEach({ (post) in
//                        print(post.1)
                        let text = post.1["text"]
                        print(post.1["id"])
                        var status: String = ""
                        let id = post.1["id"].stringValue
                        status = twtr_id + "/status/" + id
//                        print(post.1)
                        self.sources.append([twtr_id, text.rawString()!, "twitter", "nope", "twitter", "https://twitter.com/" + status])
                        DispatchQueue.main.async {
//                            self.activityIndicator.isHidden = true
                            self.sources.sort(by: {$0[0] > $1[0]})
//                            self.sourcesTable.reloadData()
                        }
                    })
                }
            })
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func closeDrawer(sender : UITapGestureRecognizer) {
        slideMode = "closed"
        UIView.animate(withDuration: slideMenuSpeed) {
            self.blurEffectView?.frame.origin.x = self.view.frame.width
            self.SlideMenuView.frame.origin.x = self.view.frame.width
            self.slideMenuContainer.frame.origin.x = self.view.frame.width
        }
    }
    
    @IBOutlet weak var backgroundView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleDidTouch),
            name: NSNotification.Name("handleTouch"),
            object: nil)
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.closeDrawer))
        self.sourcesTable.addGestureRecognizer(gesture)
        
        
        let blurEffect = UIBlurEffect(style: .regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = SlideMenuView.frame
        view.addSubview(blurEffectView!)
        sourcesTable.delegate = self
        sourcesTable.dataSource = self
        self.view.bringSubview(toFront: slideMenuContainer)
        blurEffectView?.frame.origin.x = self.view.frame.width
        SlideMenuView.frame.origin.x = self.view.frame.width
        slideMenuContainer.frame = SlideMenuView.frame
        menuFeedBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0)
        menuSourcesBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0)
        setSources()
//        menuSettingsBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0)
        sources.sort(by: {$0[0] > $1[0]})
        DispatchQueue.main.async {
            self.sourcesTable.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func menuBtnPressed(_ sender: Any) {
        slideMode = "open"
        UIView.animate(withDuration: slideMenuSpeed) {
            self.blurEffectView?.frame.origin.x -= self.blurEffectView!.frame.width
            self.SlideMenuView.frame.origin.x -= self.SlideMenuView.frame.width
            self.slideMenuContainer.frame.origin.x -= self.slideMenuContainer.frame.width
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 194
    }
    
    @IBAction func didSwipeLeft(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            let translation = sender.translation(in: self.view).x
//            print(translation)
            
            if translation > 0 { // Right
                if(self.slideMenuContainer.frame.origin.x < self.view.frame.width) {
                    UIView.animate(withDuration: 0.1) {
                        self.blurEffectView?.frame.origin.x += translation / 10
                        self.SlideMenuView.frame.origin.x += translation / 10
                        self.slideMenuContainer.frame.origin.x += translation / 10
                        self.view.layoutIfNeeded()
                    }
                }
            } else { // Left
                if(self.slideMenuContainer.frame.origin.x > self.view.frame.width - self.slideMenuContainer.frame.width) {
                    UIView.animate(withDuration: 0.1) {
                        self.blurEffectView?.frame.origin.x += translation / 10
                        self.SlideMenuView.frame.origin.x += translation / 10
                        self.slideMenuContainer.frame.origin.x += translation / 10
                        self.view.layoutIfNeeded()
                    }
                }
            }
            
        } else if sender.state == .ended {
            print(self.view.frame.width - slideMenuContainer.frame.origin.x)
            if slideMode == "closed" {
                if (slideMenuContainer.frame.origin.x <= self.view.frame.width - self.slideMenuContainer.frame.width || self.view.frame.width - self.slideMenuContainer.frame.origin.x >= 100 || self.view.frame.width - slideMenuContainer.frame.origin.x > 8) {
                    slideMode = "open"
                    UIView.animate(withDuration: 0.1, animations: {
                        self.blurEffectView?.frame.origin.x = self.view.frame.width - (self.blurEffectView?.frame.width)!
                        self.SlideMenuView.frame.origin.x = self.view.frame.width - (self.blurEffectView?.frame.width)!
                        self.slideMenuContainer.frame.origin.x = self.view.frame.width - (self.blurEffectView?.frame.width)!
                    })
                }
            } else if slideMode == "open" {
                if (slideMenuContainer.frame.origin.x > self.view.frame.width - self.slideMenuContainer.frame.width || self.view.frame.width - self.slideMenuContainer.frame.origin.x <= 100 || self.view.frame.width - slideMenuContainer.frame.origin.x > 8) {
                    slideMode = "closed"
                    UIView.animate(withDuration: 0.1, animations: {
                        self.blurEffectView?.frame.origin.x = self.view.frame.width
                        self.SlideMenuView.frame.origin.x = self.view.frame.width
                        self.slideMenuContainer.frame.origin.x = self.view.frame.width
                    })
                }
            }
        }
    }
    
    @IBAction func menuBackBtnPressed(_ sender: Any) {
        slideMode = "closed"
        
        UIView.animate(withDuration: slideMenuSpeed) {
            self.blurEffectView?.frame.origin.x = self.view.frame.width
            self.SlideMenuView.frame.origin.x = self.view.frame.width
            self.slideMenuContainer.frame.origin.x = self.view.frame.width
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        backgroundView.image = UIImage(named: "TopBar")
        let should_log = UserDefaults.standard.bool(forKey: "should_logout")
            if(should_log) {
                print("Logging Out...")
                UserDefaults.standard.set(false, forKey:"should_logout")
                dismiss(animated: true, completion: nil)
            }
    }
}
