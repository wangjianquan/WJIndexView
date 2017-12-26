//
//  IndexCell.swift
//  WJIndexTableView
//
//  Created by ulinix on 2017-12-22.
//  Copyright © 2017 wjq. All rights reserved.
//

import UIKit

class IndexCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
