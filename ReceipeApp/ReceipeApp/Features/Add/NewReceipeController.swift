//
//  NewReceipeController.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/5/22.
//

import UIKit
import IBAnimatable
import RxSwift
import RxCocoa

class NewReceipeController: BaseViewController {
    
    private lazy var vm: NewRecipeVM = {
        return NewRecipeVM()
    }()
    
    
    @IBOutlet weak var recipeNameTextField: UITextField! {
        didSet {
            recipeNameTextField.placeholder = "Recipe Name"
        }
    }
    @IBOutlet weak var recipeNameValid: ValidationLabel!
    
    @IBOutlet weak var recipeTypeDdlView: CommonDropDownView! {
        didSet {
            recipeTypeDdlView.placeHolder = "Please choose recipe type"
        }
    }
    @IBOutlet weak var recipeTypeValid: ValidationLabel!
    
    @IBOutlet weak var addImageBtn: AnimatableView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var addImagePlaceholder: UIView!
    
    @IBOutlet weak var ingrediantTextView: AnimatableTextView!
    @IBOutlet weak var ingrediantValid: ValidationLabel!
    
    @IBOutlet weak var stepTextView: AnimatableTextView!
    @IBOutlet weak var stepValid: ValidationLabel!
    @IBOutlet weak var saveBtn: AnimatableButton!
    
    private var toolBar = UIToolbar()
    private var picker  = UIPickerView()
    
    var ingredientList: [IngredientModel] = []
    let saveRecipeTrigger = PublishSubject<Void>()
    
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func makeUI() {
        self.navigationItem.title = "New Recipe"
        
        self.ingrediantTextView.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        self.stepTextView.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    override func bindViewModel() {
        
        self.vm.recipeNameValid.bind(to: self.recipeNameValid.rx.model).disposed(by: rx.disposeBag)
        self.vm.recipeTypeValid.bind(to: self.recipeTypeValid.rx.model).disposed(by: rx.disposeBag)
        self.vm.ingrediantsValid.bind(to: self.ingrediantValid.rx.model).disposed(by: rx.disposeBag)
        self.vm.stepsValid.bind(to: self.stepValid.rx.model).disposed(by: rx.disposeBag)
        
        _ = self.recipeNameTextField.rx.textInput <-> self.vm.recipeName
//        _ = self.recipeTypeDdlView.textField.rx.textInput <-> self.vm.recipeType
        _ = self.ingrediantTextView.rx.textInput <-> self.vm.ingredients
        _ = self.stepTextView.rx.textInput <-> self.vm.steps
        
        let input = NewRecipeVM.Input(saveRecipeTrigger: self.saveRecipeTrigger)
        let output = self.vm.transform(input: input)
        
        
    }
    
    private func bindView() {
        
        let addImageGesture = UITapGestureRecognizer()
        addImageGesture.numberOfTapsRequired = 1
        addImageGesture.rx
            .event
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.showImagePickerOption()
            })
            .disposed(by: rx.disposeBag)
        self.addImageBtn.isUserInteractionEnabled = true
        self.addImageBtn.addGestureRecognizer(addImageGesture)
        
        let typeGesture = UITapGestureRecognizer()
        typeGesture.numberOfTapsRequired = 1
        typeGesture.rx
            .event
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.view.endEditing(true)
                self.setupFilterView()
            })
            .disposed(by: rx.disposeBag)
        self.recipeTypeDdlView.containerView.isUserInteractionEnabled = true
        self.recipeTypeDdlView.containerView.addGestureRecognizer(typeGesture)
        
        self.saveBtn.rx
            .tap
            .throttle(RxTimeInterval.milliseconds(Int(0.3)), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.vm.recipeType.accept(self.recipeTypeDdlView.textField.text ?? "")
                self.saveRecipeTrigger.onNext(())
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    private func setupFilterView() {
        self.picker = UIPickerView.init()
        picker.dataSource = self
        picker.delegate = self
        self.picker.backgroundColor = UIColor.white
        self.picker.setValue(UIColor.black, forKey: "textColor")
        self.picker.autoresizingMask = .flexibleWidth
        self.picker.contentMode = .center
        self.picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(self.picker)
                    
        self.toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 40))
        self.toolBar.barStyle = .blackTranslucent
        self.toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(self.dismissPickerView))]
        self.view.addSubview(self.toolBar)
    }
    
    @objc func dismissPickerView() {
        self.toolBar.removeFromSuperview()
        self.picker.removeFromSuperview()
    }

}

extension NewReceipeController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RecipeManager.shared.recipeTypeList.value.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return RecipeManager.shared.recipeTypeList.value[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let model = RecipeManager.shared.recipeTypeList.value[row]
        self.recipeTypeDdlView.textValue = model
    }
    
}

extension NewReceipeController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePickerOption() {
        let alert = UIAlertController(title: "Select Option", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Alert", message: "Please allow ReceipeApp to access to your camera.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Alert", message: "Please allow ReceipeApp to access your gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        switch picker.sourceType {
        case .camera:
            if let image = info[.originalImage] as? UIImage {
                self.dismiss(animated: true)
                
                self.addImagePlaceholder.isHidden = true
                self.recipeImageView.image = image
                
                if let imageData = image.jpegData(compressionQuality: 0.7) {
                    self.vm.recipeImageData.accept(imageData)
                }
            }
        case .savedPhotosAlbum, .photoLibrary:
            if let image = info[.originalImage] as? UIImage {
                self.dismiss(animated: true) {
                    
                    self.addImagePlaceholder.isHidden = true
                    self.recipeImageView.image = image
                    
                    if let imageData = image.jpegData(compressionQuality: 0.7) {
                        self.vm.recipeImageData.accept(imageData)
                    }
                }
            }
        @unknown default:
            fatalError("Could not retrieve anything from photo.")
        }
    }
    
}
