//
//  MainViewController.swift
//  Funnel
//
//  Created by Jeremy Irvine on 2/3/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit

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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sourceCell", for: indexPath) as! SourceListCell
            return cell
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
