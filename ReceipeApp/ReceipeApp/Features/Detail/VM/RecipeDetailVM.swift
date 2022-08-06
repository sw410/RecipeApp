//
//  RecipeDetailVM.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/6/22.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class RecipeDetailVM: BaseViewModel, ViewModelType {
    
    let recipeId: BehaviorRelay<Int> = .init(value: 0)
    let recipeName: BehaviorRelay<String> = .init(value: "")
    let recipeType: BehaviorRelay<String> = .init(value: "")
    let ingredients: BehaviorRelay<String> = .init(value: "")
    let steps: BehaviorRelay<String> = .init(value: "")
    
    let editMode = BehaviorRelay<Bool>.init(value: false)
    let model = BehaviorRelay<Recipe?>.init(value: nil)
    
    var recipeNameValid: BehaviorRelay<ValidationModel> = BehaviorRelay.init(value: ValidationModel())
    var ingrediantsValid: BehaviorRelay<ValidationModel> = BehaviorRelay.init(value: ValidationModel())
    var stepsValid: BehaviorRelay<ValidationModel> = BehaviorRelay.init(value: ValidationModel())
    
    convenience init(recipeId: Int) {
        self.init()
        self.recipeId.accept(recipeId)
    }
    
    struct Input {
        let deleteTrigger: PublishSubject<Int>
        let saveTrigger: PublishSubject<Void>
    }
    
    struct Output {
        let deleteSuccess: PublishSubject<Void>
    }
    
    func transform(input: RecipeDetailVM.Input) -> RecipeDetailVM.Output {
        
        let deleteSuccess = PublishSubject<Void>()
        
        Observable.array(from: Recipe().getCurrentRecipe(id: self.recipeId.value))
            .subscribe(onNext: { [weak self] data in
                guard let `self` = self else { return }
                print(data)
                self.model.accept(data.first)
            })
            .disposed(by: rx.disposeBag)
        
        self.model.asObservable()
            .subscribe(onNext: { [weak self] data in
                guard let `self` = self else { return }
                self.recipeId.accept(data?.id ?? 0)
                self.recipeName.accept(data?.title ?? "")
                self.recipeType.accept(data?.type ?? "")
                self.ingredients.accept(data?.ingrediant ?? "")
                self.steps.accept(data?.steps ?? "")
            })
            .disposed(by: rx.disposeBag)
        
        input.deleteTrigger
            .subscribe(onNext: { [weak self] id in
                guard let _ = self else { return }
                Recipe().deleteRecipe(id: id)
                deleteSuccess.onNext(())
            })
            .disposed(by: rx.disposeBag)
        
        input.saveTrigger
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                
                if let recipe = Recipe().getRecipe(id: self.recipeId.value) {
                    print(recipe)
                    let recipeRef = ThreadSafeReference(to: recipe)
                    DispatchQueue(label: "background").async {
                        autoreleasepool {
                            guard let config = RealmManager.shared.configuration, let backgroundRealm = try? Realm(configuration: config), let recipe = backgroundRealm.resolve(recipeRef) else { return }
                            
                            print("xxxx \(self.recipeName.value)")
                            
                            try? backgroundRealm.safeWrite {
                                recipe.title = self.recipeName.value
                                recipe.type = self.recipeType.value
                                recipe.ingrediant = self.ingredients.value
                                recipe.steps = self.steps.value
                            }
                        }
                    }
                }
                
            })
            .disposed(by: rx.disposeBag)
        
        return Output(deleteSuccess: deleteSuccess)
    }
    
}

extension RecipeDetailVM {
    
    private func validate() -> Bool {
        
        self.recipeName
            .map { $0.count > 0 }
            .share(replay: 1)
            .subscribe(onNext: { [weak self] status in
                guard let superSelf = self else { return }
                superSelf.recipeNameValid.accept(ValidationHelper.bindStatus(status: status, message: "Recipe Name cannot be empty"))
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
        
        
        return ValidationHelper.validate(validations: [self.recipeNameValid.value, self.ingrediantsValid.value, self.stepsValid.value])
    }
    
}
