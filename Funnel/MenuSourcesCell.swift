//
//  MenuSourcesCell.swift
//  Funnel
//
//  Created by Jeremy Irvine on 4/18/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit

class MenuSourcesCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var txt: UILabel!
    @IBOutlet weak var btn: UIButton!
    var btn_index = -1
    var btn_action: String = "remove"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func btnPressed(_ sender: Any) {
        if(btn_index == -1) {
            print("ERROR: Index == -1, action cancelled")
        } else {
            if(btn_action == "remove") {
                NotificationCenter.default.post(name: .removeSourceItem, object: self, userInfo: ["index": btn_index])
            } else if (btn_action == "add") {
                NotificationCenter.default.post(name: .addSourceItem, object: self, userInfo: ["index": btn_index])
            }
        }
    }
    
}
