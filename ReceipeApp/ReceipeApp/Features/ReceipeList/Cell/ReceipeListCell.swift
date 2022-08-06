//
//  ReceipeListCell.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/5/22.
//

import UIKit
import IBAnimatable

class ReceipeListCell: UITableViewCell {
    
    @IBOutlet weak var shadowView: AnimatableView!
    @IBOutlet weak var shadowView2: AnimatableView!
    @IBOutlet weak var recipeImageView: AnimatableImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.shadowView.dropShadow(scale: true, offSet: CGSize(width: 0, height: 0))
        self.shadowView2.dropShadow(scale: true, offSet: CGSize(width: 0, height: 0))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var model: Recipe? {
        didSet {
            guard let model = model else { return }
            
            if let imageData = model.receipeImageData {
                self.recipeImageView.image = UIImage(data: imageData)
            }
            self.titleLabel.text = model.title
            self.dateLabel.text = model.type
        }
    }
    
}
