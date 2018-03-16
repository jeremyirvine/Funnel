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
    
    var shouldLogout = false
    
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
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sourceCell", for: indexPath) as! SourceListCell
            cell.articlePreview.text = sources[indexPath.row][1]
            cell.articleTitle.text = sources[indexPath.row][0]
            cell.sourceName.text = sources[indexPath.row][4]
            if(sources[indexPath.row][4] == "twitter") {
                cell.icon.image = UIImage(named: "twitter icon enabled")
                cell.icon.layer.cornerRadius = 0
                cell.articlePreviewImg.isHidden = true
            } else {
                cell.icon.layer.cornerRadius = cell.icon.frame.height / 2
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
            let parser = FeedParser(URL: feedurl!)
            print("URL:", source[1])
            parser?.parseAsync(result: { (result) in
                print("Success")
                result.rssFeed?.items?.forEach({ (entry) in
                    print("rssFeed in", source[1])
                    let str = entry.content?.contentEncoded?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "\n", with: "")
                    self.sources.append([entry.title!, str!, (result.rssFeed?.image?.url!)!, "nope", source[0]])
                    DispatchQueue.main.async {
                        self.sources.sort(by: {$0[0] > $1[0]})
                        self.sourcesTable.reloadData()
                    }
                })
                result.atomFeed?.entries?.forEach({ (entry) in
                    print("atomFeed in", source[1])
                    let str = entry.content?.value?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "\n", with: "")
                    let date = entry.published
                    self.sources.append([entry.title!, str!, (result.atomFeed?.icon)!, "nope", source[0], (date?.toString(dateFormat: "MM-dd-yyy"))!])
                    DispatchQueue.main.async {
                        self.sources.sort(by: {$0[0] > $1[0]})
                        self.sourcesTable.reloadData()
                    }
                })
                result.jsonFeed?.items?.forEach({ (entry) in
                    print("jsonFeed in", source[1])
                    let str = entry.contentText
                    let date = entry.datePublished
                    self.sources.append([entry.title!, str!, (result.jsonFeed?.icon)!, "nope", source[0], (date?.toString(dateFormat: "MM-dd-yyy"))!])
                    DispatchQueue.main.async {
                        self.sources.sort(by: {$0[0] > $1[0]})
                        self.sourcesTable.reloadData()
                    }
                })
            })
        }
        
        socialData.forEach { (source) in
            if(source[1] == "twitter") {
                grabSocial(twtr_id: source[0])
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
    }
    
    func grabSocial(twtr_id: String) {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            let parameter : [String : AnyObject] = ["screen_name" : twtr_id as AnyObject , "count" : "10" as AnyObject]
            let req = client.urlRequest(withMethod: "GET", urlString: "https://api.twitter.com/1.1/statuses/user_timeline.json", parameters: parameter, error: nil)
            NSURLConnection.sendAsynchronousRequest(req, queue: .main, completionHandler: { (response, data, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    print("Got Social Response: ")
                    SwiftyJSON.JSON(data).forEach({ (post) in
                        print(post.1["text"])
                        let text = post.1["text"]
                        self.sources.append([twtr_id, text.rawString()!, "twitter", "nope", "twitter"])
                        DispatchQueue.main.async {
                            self.sources.sort(by: {$0[0] > $1[0]})
                            self.sourcesTable.reloadData()
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
