//
//  ReceipeListController.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/5/22.
//

import UIKit
import IBAnimatable
import RxCocoa
import RxSwift

class ReceipeListController: BaseViewController {
    
    private lazy var vm: RecipeListVM = {
        return RecipeListVM()
    }()
    let recipeList = BehaviorRelay<[Recipe]>.init(value: [])
    let filterRecipeList = BehaviorRelay<[Recipe]>.init(value: [])
    let filterTrigger = PublishSubject<Void>()
    
    @IBOutlet weak var searchView: AnimatableView!
    private var toolBar = UIToolbar()
    private var picker  = UIPickerView()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var filterBtn: AnimatableButton!
    
    private var isPickerViewShowing: Bool = false
    private var type: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupTableView()
        self.makeUI()
        self.bindViewModel()
        self.bindView()
    }
    
    override func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(ReceipeListCell.getNib(), forCellReuseIdentifier: ReceipeListCell.identifier)
    }
    
    override func makeUI() {
        let filterBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: R.image.ic_filter()?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.openPickerView))
        self.navigationItem.rightBarButtonItem = filterBarButtonItem
        
        self.searchView.dropShadow()
    }
    
    override func bindViewModel() {
        let input = RecipeListVM.Input(firstTrigger: Observable.just(()))
        let output = self.vm.transform(input: input)
        
        output.recipeList
            .subscribe(onNext: { [weak self] data in
                guard let `self` = self else { return }
                self.recipeList.accept(data ?? [])
                self.filterRecipeList.accept(data ?? [])
                self.tableView.reloadData()
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    private func bindView() {
        self.addBtn.rx
            .tap
            .throttle(RxTimeInterval.milliseconds(Int(0.3)), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.navigationController?.pushViewController(NewReceipeController(), animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        self.filterBtn.rx
            .tap
            .throttle(RxTimeInterval.milliseconds(Int(0.3)), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                if !self.isPickerViewShowing {
                    self.setupFilterView()
                }
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
        self.picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 250, width: UIScreen.main.bounds.size.width, height: 250)
        self.view.addSubview(self.picker)
                    
        self.toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 260, width: UIScreen.main.bounds.size.width, height: 40))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.dismissPickerView))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.donePickerView))
        self.toolBar.items = [cancelButton, spaceButton, doneButton]
        self.toolBar.sizeToFit()
        self.view.addSubview(self.toolBar)
    
        self.isPickerViewShowing = true
    }
    
    @objc func openPickerView() {
        self.setupFilterView()
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
        
        if self.type == "" {
            self.filterRecipeList.accept(self.recipeList.value)
        } else {
            self.filterRecipeList.accept(self.recipeList.value.filter({ $0.type == self.type }))
        }
        self.tableView.reloadData()
        
    }

}

extension ReceipeListController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.vm.recipeTypeList.value.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.vm.recipeTypeList.value[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let model = self.vm.recipeTypeList.value[row]
        if row == 0 {
            self.type = ""
        } else {
            self.type = model
        }
    }
    
}

extension ReceipeListController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterRecipeList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReceipeListCell.identifier, for: indexPath) as! ReceipeListCell
        cell.model = self.filterRecipeList.value[indexPath.row]
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.filterRecipeList.value[indexPath.row]
        self.navigationController?.pushViewController(RecipeDetailController(vm: RecipeDetailVM(recipeId: model.id)), animated: true)
    }
    
}
