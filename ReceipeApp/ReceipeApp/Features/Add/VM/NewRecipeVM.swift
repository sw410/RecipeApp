//
//  NewIngredientVM.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/5/22.
//

import Foundation
import RxSwift
import RxCocoa

class NewRecipeVM: BaseViewModel, ViewModelType {
    
    let recipeImageData = BehaviorRelay<Data?>.init(value: nil)
    let recipeName = BehaviorRelay<String>.init(value: "")
    let recipeType = BehaviorRelay<String>.init(value: "")
    let ingredients = BehaviorRelay<String>.init(value: "")
    let steps = BehaviorRelay<String>.init(value: "")
    
    var recipeNameValid: BehaviorRelay<ValidationModel> = BehaviorRelay.init(value: ValidationModel())
    var recipeTypeValid: BehaviorRelay<ValidationModel> = BehaviorRelay.init(value: ValidationModel())
    var ingrediantsValid: BehaviorRelay<ValidationModel> = BehaviorRelay.init(value: ValidationModel())
    var stepsValid: BehaviorRelay<ValidationModel> = BehaviorRelay.init(value: ValidationModel())
    
    struct Input {
        let saveRecipeTrigger: PublishSubject<Void>
    }
    
    struct Output {
        
    }
    
    func transform(input: NewRecipeVM.Input) -> NewRecipeVM.Output {
        
        input.saveRecipeTrigger
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                
                if !self.validate() {
                    return
                }
                
                let recipe = Recipe()
                recipe.id = Recipe().incrementID()
                recipe.title = self.recipeName.value
                recipe.dateTime = Date()
                recipe.ingrediant = self.ingredients.value
                recipe.steps = self.steps.value
                recipe.type = self.recipeType.value
                recipe.receipeImageData = self.recipeImageData.value
                RealmManager.shared.add([recipe])
            })
            .disposed(by: rx.disposeBag)
        
        return Output()
    }
    
}

extension NewRecipeVM {
    
    func validate() -> Bool {
        
        self.recipeName
            .map { $0.count > 0 }
            .share(replay: 1)
            .subscribe(onNext: { [weak self] status in
                guard let superSelf = self else { return }
                superSelf.recipeNameValid.accept(ValidationHelper.bindStatus(status: status, message: "Recipe Name cannot be empty"))
            })
            .disposed(by: rx.disposeBag)
        
        self.recipeType
            .map { !$0.isEmpty }
            .share(replay: 1)
            .subscribe(onNext: { [weak self] status in
                guard let superSelf = self else { return }
                superSelf.recipeTypeValid.accept(ValidationHelper.bindStatus(status: status, message: "Please select a recipe type"))
            })
            .disposed(by: rx.disposeBag)
        
        self.ingredients
            .map { $0.count > 0 }
            .share(replay: 1)
            .subscribe(onNext: { [weak self] status in
                guard let superSelf = self else { return }
                superSelf.ingrediantsValid.accept(ValidationHelper.bindStatus(status: status, message: "Ingrediant cannot be empty"))
            })
            .disposed(by: rx.disposeBag)
        
        self.steps
            .map { $0.count > 0 }
            .share(replay: 1)
            .subscribe(onNext: { [weak self] status in
                guard let superSelf = self else { return }
                superSelf.stepsValid.accept(ValidationHelper.bindStatus(status: status, message: "Steps cannot be empty"))
            })
            .disposed(by: rx.disposeBag)
        
        
        return ValidationHelper.validate(validations: [self.recipeNameValid.value, self.recipeTypeValid.value, self.ingrediantsValid.value, self.stepsValid.value])
    }
    
}
