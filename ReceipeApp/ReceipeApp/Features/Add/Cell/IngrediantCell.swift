//
//  IngrediantCell.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/5/22.
//

import UIKit
import IBAnimatable
import RxSwift
import RxCocoa

class IngrediantCell: UITableViewCell {
    
    @IBOutlet weak var textview: UITextField! {
        didSet {
            textview.placeholder = "Ingredient Name"
        }
    }
    @IBOutlet weak var editBtn: UIButton! {
        didSet {
            editBtn.isHidden = true
        }
    }
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var checkBtn: UIButton!
    
    var saveCallback: ((String?) -> ())?
    var deleteCallback: (() -> ())?
    
    var cellDisposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.cellDisposeBag = DisposeBag()
        
        self.editBtn.isHidden = true
        self.deleteBtn.isHidden = false
        self.checkBtn.isHidden = false
    }
    
    func configureCell() {
        
        self.checkBtn.rx
            .tap
            .throttle(RxTimeInterval.milliseconds(Int(0.3)), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                
//                if self.textview.text?.isEmpty == true {
//                    print("Empty")
//                } else {
//                    self.saveCallback?(self.textview.text ?? "")
//                }
                self.saveCallback?(self.textview.text ?? "")
                
            })
            .disposed(by: self.cellDisposeBag)
        
        self.deleteBtn.rx
            .tap
            .throttle(RxTimeInterval.milliseconds(Int(0.3)), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.deleteCallback?()
            })
            .disposed(by: self.cellDisposeBag)
    }
    
    var model: IngredientModel? {
        didSet {
            guard let model = model else { return }
            self.textview.text = model.ingredientName
            self.textview.isEnabled = !model.isSaved
            self.editBtn.isHidden = !model.isSaved
            self.checkBtn.isHidden = model.isSaved
        }
    }
    
}
