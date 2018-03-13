//
//  MainViewController.swift
//  Funnel
//
//  Created by Jeremy Irvine on 2/3/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit
import FeedKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var slideMenuContainer: UIView!
    @IBOutlet weak var SlideMenuView: UIView!
    @IBOutlet weak var sourcesTable: UITableView!
    @IBOutlet weak var menuFeedBtn: UIButton!
    @IBOutlet weak var menuSourcesBtn: UIButton!
    @IBOutlet weak var menuSettingsBtn: UIButton!
    
    var slideMode = "closed"
    
    let slideMenuSpeed: Double = 0.2
    var blurEffectView: UIVisualEffectView?
    
    var sources: [[String]] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sources.count
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
            }
            do {
                if let url = URL(string: sources[indexPath.row][2]) {
                    if let data = try? Data(contentsOf: url) {
                        if let source = UIImage(data: data) {
                            cell.icon.image = source
                        } else {
                            cell.icon.image = UIImage(named: "Unkown Image")
                        }
                    } else {
                        cell.icon.image = UIImage(named: "Unkown Image")
                    }
                } else {
                    cell.icon.image = UIImage(named: "Unknown_Image")
                }
                
            } catch {
                print(error.localizedDescription)
        }

            return cell
    }
    
    func setSources() {
        let ud = UserDefaults.standard
        for (key, value) in ud.dictionaryRepresentation() {
            print("\(key) = \(value) \n")
        }
        let rssData = ud.object(forKey: "rss") as! [[String]]
        print(rssData.count)
        rssData.forEach { (source) in
            let feedurl = URL(string: source[1])
            let parser = FeedParser(URL: feedurl!)
            print("URL:", source[1])
            parser?.parseAsync(result: { (result) in
                print("Success")
                print(result.rssFeed?.items?.forEach({ (entry) in
                    print("rssFeed in", source[1])
                    //                print(entry.title)
                    let str = entry.content?.contentEncoded?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "\n", with: "")
                    //                print(entry.content?.value?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "\n", with: "")    )
                    self.sources.append([entry.title!, str!, (result.rssFeed?.image?.url!)!, "nope", source[0]])
                    DispatchQueue.main.async {
                        self.sourcesTable.reloadData()
                    }
                }))
                print(result.atomFeed?.entries?.forEach({ (entry) in
                    print("atomFeed in", source[1])
                    //                print(entry.title)
                    let str = entry.content?.value?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "\n", with: "")
                    //                print(entry.content?.value?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "\n", with: "")    )
                    self.sources.append([entry.title!, str!, (result.atomFeed?.icon)!, "nope", source[0]])
                    DispatchQueue.main.async {
                        self.sourcesTable.reloadData()
                    }
                }))
                result.jsonFeed?.items?.forEach({ (entry) in
                    print("jsonFeed in", source[1])
                    //                print(entry.title)
                    let str = entry.contentText
                    //                print(entry.content?.value?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "\n", with: "")    )
                    self.sources.append([entry.title!, str!, (result.jsonFeed?.icon)!, "nope", source[0]])
                    DispatchQueue.main.async {
                        self.sourcesTable.reloadData()
                    }
                })
            })
        }
        
        
        // Schema:
        // 0: Article Title
        // 1: Preview Content
        // 2: Source Thumbnail Url?
        // 3: Article Thumbnail Url?
        // 4: Source Name
        
//        sources = [["Test", "Lol this is text?", "nope", "nope", "Ars Technica"],
//                   ["jezza_dev", "I know iBoot got leaked, but did the SecureROM or BootROM get leaked?", "nope", "nope", "twitter"],
//                   ["FCE365", "AAAAAAAAAAAAAAAAAA", "nope", "nope", "twitter"]]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var backgroundView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
}
