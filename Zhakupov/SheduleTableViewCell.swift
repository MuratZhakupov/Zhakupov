//
//  SheduleTableViewCell.swift
//  Zhakupov
//
//  Created by Murat Zhakupov on 2/25/20.
//  Copyright © 2020 Murat Zhakupov. All rights reserved.
//

import UIKit

class SheduleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var sportNameLabel: UILabel!
    
    @IBOutlet weak var teacherLabel: UILabel!
    
    @IBOutlet weak var roomLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
