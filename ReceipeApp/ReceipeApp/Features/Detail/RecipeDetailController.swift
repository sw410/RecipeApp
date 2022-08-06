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
    
    private var isPickerViewShowing: Bool = false
    private var currentSelectedRow: Int = 0
    private var toolBar = UIToolbar()
    private var picker  = UIPickerView()
    
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
        
        RecipeManager.shared.recipeTypeList
            .asObservable()
            .subscribe(onNext: { [weak self] data in
                guard let `self` = self else { return }
                if let index = data.firstIndex(where: { $0 == self.vm.recipeType.value }) {
                    self.currentSelectedRow = index
                }
            })
            .disposed(by: rx.disposeBag)
        
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
                    
                    self.recipeImageView.isUserInteractionEnabled = true
                } else {
                    let editBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.editTapped))
                    self.navigationItem.rightBarButtonItem = editBarButtonItem
                    
                    self.recipeImageView.isUserInteractionEnabled = false
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
                self.navigationController?.popViewController(animated: true)
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
        
        let addImageGesture = UITapGestureRecognizer()
        addImageGesture.numberOfTapsRequired = 1
        addImageGesture.rx
            .event
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.showImagePickerOption()
            })
            .disposed(by: rx.disposeBag)
        self.recipeImageView.addGestureRecognizer(addImageGesture)
    
        self.deleteBtn.rx
            .tap
            .throttle(RxTimeInterval.milliseconds(Int(0.3)), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.showDeleteAlert()
            })
            .disposed(by: rx.disposeBag)
        
        let typeGesture = UITapGestureRecognizer()
        typeGesture.numberOfTapsRequired = 1
        typeGesture.rx
            .event
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.view.endEditing(true)
                if !self.isPickerViewShowing {
                    self.setupFilterView()
                }
            })
            .disposed(by: rx.disposeBag)
        self.recipeTypeDropDown.containerView.isUserInteractionEnabled = true
        self.recipeTypeDropDown.containerView.addGestureRecognizer(typeGesture)
    }
    
    private func setupFilterView() {
        self.picker = UIPickerView.init()
        picker.dataSource = self
        picker.delegate = self
        self.picker.backgroundColor = UIColor.white
        self.picker.setValue(UIColor.black, forKey: "textColor")
        self.picker.autoresizingMask = .flexibleWidth
        self.picker.contentMode = .center
        self.picker.selectRow(self.currentSelectedRow, inComponent: 0, animated: true)
        self.picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 350, width: UIScreen.main.bounds.size.width, height: 350)
        self.view.addSubview(self.picker)
                    
        self.toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 360, width: UIScreen.main.bounds.size.width, height: 40))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.dismissPickerView))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.donePickerView))
        self.toolBar.items = [cancelButton, spaceButton, doneButton]
        self.toolBar.sizeToFit()
        self.view.addSubview(self.toolBar)
    
        self.isPickerViewShowing = true
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
        self.vm.recipeType.accept(self.recipeTypeDropDown.textField.text ?? "")
        self.saveTrigger.onNext(())
    }
    
    @objc func dismissPickerView() {
        self.toolBar.removeFromSuperview()
        self.picker.removeFromSuperview()
        
        self.isPickerViewShowing = false
    }
    
    @objc func donePickerView() {
        self.toolBar.removeFromSuperview()
        self.picker.removeFromSuperview()
        
        self.isPickerViewShowing = false
    }
}

extension RecipeDetailController: UIPickerViewDataSource, UIPickerViewDelegate {
    
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
        self.currentSelectedRow = row
        self.recipeTypeDropDown.textValue = model
    }
    
}

extension RecipeDetailController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

                self.recipeImageView.image = image
                
                if let imageData = image.jpegData(compressionQuality: 0.7) {
                    self.vm.recipeImageData.accept(imageData)
                }
            }
        case .savedPhotosAlbum, .photoLibrary:
            if let image = info[.originalImage] as? UIImage {
                self.dismiss(animated: true) {
                    
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
