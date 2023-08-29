//
//  FeedTableViewCell.swift
//  InsightGauge
//
//  Created by Mac on 29.08.2023.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var progressBar: UIStackView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var firstImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
