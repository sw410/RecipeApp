//
//  NewStepsCell.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/6/22.
//

import UIKit

class NewStepsCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textView.adjustUITextViewHeight()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension UITextView {
    
    func adjustUITextViewHeight() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.sizeToFit()
        self.isScrollEnabled = false
    }
}
