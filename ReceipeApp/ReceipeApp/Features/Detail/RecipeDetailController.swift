//
//  RecipeDetailController.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/6/22.
//

import UIKit
import IBAnimatable
import RxSwift
import RxCocoa

class RecipeDetailController: BaseViewController {

    @IBOutlet weak var recipeImageView: AnimatableImageView!
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeNameStackView: UIStackView! {
        didSet {
            recipeNameStackView.isHidden = true
        }
    }
    @IBOutlet weak var recipeNameTextView: UITextField!
    @IBOutlet weak var recipeNameValid: ValidationLabel!
    
    @IBOutlet weak var recipeTypeLabel: UILabel!
    @IBOutlet weak var recipeTypeStackView: UIStackView! {
        didSet {
            recipeTypeStackView.isHidden = true
        }
    }
    @IBOutlet weak var recipeTypeDropDown: CommonDropDownView!
    
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var ingredientsStackView: UIStackView!
    @IBOutlet weak var ingredientsTextView: AnimatableTextView!
    @IBOutlet weak var ingredientsValid: ValidationLabel!
    
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var stepsStackView: UIStackView!
    @IBOutlet weak var stepsTextView: AnimatableTextView!
    @IBOutlet weak var stepsValid: ValidationLabel!
    
    @IBOutlet weak var deleteBtn: AnimatableButton!
    
    var vm = RecipeDetailVM()
    let deleteTrigger = PublishSubject<Int>()
    let saveTrigger = PublishSubject<Void>()
    
    convenience init(vm: RecipeDetailVM) {
        self.init()
        self.vm = vm
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.makeUI()
        self.bindViewModel()
        self.bindView()
    }
    
    override func makeUI() {
       
    }
    
    override func bindViewModel() {
        
        self.vm.editMode.asObservable()
            .subscribe(onNext: { [weak self] mode in
                guard let `self` = self else { return }
                
                self.recipeNameStackView.isHidden = !mode
                self.recipeNameLabel.isHidden = mode
                self.recipeTypeStackView.isHidden = !mode
                self.recipeTypeLabel.isHidden = mode
                self.ingredientsStackView.isHidden = !mode
                self.ingredientsLabel.isHidden = mode
                self.stepsStackView.isHidden = !mode
                self.stepsLabel.isHidden = mode
                
                if mode {
                    let saveBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.saveTapped))
                    self.navigationItem.rightBarButtonItem = saveBarButtonItem
                } else {
                    let editBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.editTapped))
                    self.navigationItem.rightBarButtonItem = editBarButtonItem
                }
                
            })
            .disposed(by: rx.disposeBag)
        
        self.vm.recipeNameValid.bind(to: self.recipeNameValid.rx.model).disposed(by: rx.disposeBag)
        self.vm.ingrediantsValid.bind(to: self.ingredientsValid.rx.model).disposed(by: rx.disposeBag)
        self.vm.stepsValid.bind(to: self.stepsValid.rx.model).disposed(by: rx.disposeBag)
        
        _ = self.recipeNameTextView.rx.textInput <-> self.vm.recipeName
        _ = self.stepsTextView.rx.textInput <-> self.vm.steps
        _ = self.ingredientsTextView.rx.textInput <-> self.vm.ingredients
        
        let input = RecipeDetailVM.Input(deleteTrigger: self.deleteTrigger, saveTrigger: self.saveTrigger)
        let output = self.vm.transform(input: input)
        
        output.deleteSuccess
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: rx.disposeBag)
        
        
        self.vm.model.asObservable()
            .subscribe(onNext: { [weak self] data in
                guard let `self` = self else { return }
                
                if let imageData = data?.receipeImageData {
                    self.recipeImageView.image = UIImage(data: imageData)
                }
                self.navigationItem.title = data?.title ?? ""
                self.recipeNameLabel.text = data?.title ?? ""
                
                self.recipeTypeDropDown.textField.text = data?.type ?? ""
                self.recipeTypeLabel.text = data?.type ?? ""
                
                self.ingredientsLabel.setLineSpacing(alignment: .left, spacing: 6, text: data?.ingrediant ?? "")
                self.stepsLabel.setLineSpacing(alignment: .left, spacing: 6, text: data?.steps ?? "")
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func bindView() {
    
        self.deleteBtn.rx
            .tap
            .throttle(RxTimeInterval.milliseconds(Int(0.3)), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.showDeleteAlert()
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func showDeleteAlert() {
        let alert = UIAlertController(title: "Delete Recipe?", message: "Do you want to delete this recipe?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.deleteTrigger.onNext(self.vm.recipeId.value)
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @objc func editTapped() {
        self.vm.editMode.accept(true)
    }
    
    @objc func saveTapped() {
        self.vm.editMode.accept(false)
        self.saveTrigger.onNext(())
    }
}
