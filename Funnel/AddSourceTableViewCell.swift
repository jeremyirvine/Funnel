//
//  AddSourceTableViewCell.swift
//  Funnel
//
//  Created by Jeremy Irvine on 2/5/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit
import TwitterKit

class AddSourceTableViewCell: UITableViewCell {

    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var redditBtn: UIButton!
    @IBOutlet weak var twitterBtn: UIButton!
    @IBOutlet weak var instagramBtn: UIButton!
    @IBOutlet weak var thumbnailImg: UIImageView!
    
    @IBOutlet weak var searchImage: UIImageView!
    var buttonSel = "instagram"
    var ud = UserDefaults.standard
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        switch UserDefaults.standard.string(forKey: "_tmp_social-btn-state")! {
        case "instagram":
            disableAllBtns()
            instagramBtn.setImage(UIImage(named: "instagram icon enabled"), for: .normal)
        case "reddit":
            disableAllBtns()
            redditBtn.setImage(UIImage(named: "reddit icon enabled"), for: .normal)
        case "twitter":
            disableAllBtns()
            twitterBtn.setImage(UIImage(named: "twitter icon enabled"), for: .normal)
        case "facebook":
            disableAllBtns()
            twitterBtn.setImage(UIImage(named: "facebook icon enabled"), for: .normal)
        default:
            print("Error: Button type is invalid (AddSourceTableViewCell 41:14)")
            disableAllBtns()
            instagramBtn.setImage(UIImage(named: "instagram icon enabled"), for: .normal)
        }
    }
    @IBAction func instagramPressed(_ sender: Any) {
        disableAllBtns()
        instagramBtn.setImage(UIImage(named: "instagram icon enabled"), for: .normal)
        ud.set("instagram", forKey: "_tmp_social-btn-state")
    }
    
    @IBAction func facebookPressed(_ sender: Any) {
        disableAllBtns()
        facebookBtn.setImage(UIImage(named: "facebook icon enabled"), for: .normal)
        ud.set("facebook", forKey: "_tmp_social-btn-state")
    }
    @IBAction func twitterPressed(_ sender: Any) {
        disableAllBtns()
        twitterBtn.setImage(UIImage(named: "twitter icon enabled"), for: .normal)
        ud.set("twitter", forKey: "_tmp_social-btn-state")
        if(TWTRTwitter.sharedInstance().sessionStore.session()?.authToken == nil) {
            TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                if (session != nil) {
                    TWTRTwitter.sharedInstance().sessionStore.save(session!, completion: {_,_ in })
                } else {
                    print("An Error Occurred!")
                }
            })
        }
    }
    @IBAction func redditPressed(_ sender: Any) {
        disableAllBtns()
        redditBtn.setImage(UIImage(named: "reddit icon enabled"), for: .normal)
        ud.set("reddit", forKey: "_tmp_social-btn-state")
    }
    
    func disableAllBtns() {
        redditBtn.setImage(UIImage(named: "reddit icon disabled"), for: .normal)
        instagramBtn.setImage(UIImage(named: "instagram icon disabled"), for: .normal)
        twitterBtn.setImage(UIImage(named: "twitter icon disabled"), for: .normal)
        facebookBtn.setImage(UIImage(named: "facebook icon disabled"), for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
