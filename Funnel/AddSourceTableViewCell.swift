//
//  AddSourceTableViewCell.swift
//  Funnel
//
//  Created by Jeremy Irvine on 2/5/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit

class AddSourceTableViewCell: UITableViewCell {

    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var twitterBtn: UIButton!
    @IBOutlet weak var instagramBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
