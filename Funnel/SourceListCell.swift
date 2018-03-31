//
//  SourceListCell.swift
//  Funnel
//
//  Created by Jeremy Irvine on 2/21/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit

class SourceListCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var sourceName: UILabel!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articlePreview: UILabel!
    @IBOutlet weak var articlePreviewImg: UIImageView!
    var id = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        icon.layer.cornerRadius = icon.frame.height / 2
    }

    @IBAction func didTouchCell(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("handleTouch"), object: nil, userInfo: ["id": id])
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
        
        // Configure the view for the selected state
    }

}
