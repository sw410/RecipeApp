//
//  ReceipeVM.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/5/22.
//

import Foundation
import RxSwift
import RxCocoa

class RecipeListVM: BaseViewModel, ViewModelType {
    
    let recipeTypeList = BehaviorRelay<[String]>.init(value: [])
    
    struct Input {
        let firstTrigger: Observable<Void>
    }
    
    struct Output {
        let recipeList: BehaviorRelay<[Recipe]?>
    }
    
    func transform(input: RecipeListVM.Input) -> RecipeListVM.Output {
        
        let recipeList = BehaviorRelay<[Recipe]?>.init(value: [])
        
        input.firstTrigger
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                
                RecipeManager.shared.recipeTypeList
                    .asObservable()
                    .subscribe(onNext: { [weak self] data in
                        guard let `self` = self else { return }
                        var item: [String] = []
                        item.append("All")
                        
                        self.recipeTypeList.accept(item + data)
                    })
                    .disposed(by: self.rx.disposeBag)
                
            })
            .disposed(by: rx.disposeBag)
        
        Observable.arrayWithChangeset(from: Recipe().getAllRecipe())
            .subscribe(onNext: { [weak self] list, changes in
                guard let _ = self else { return }
                print(list)
                recipeList.accept(list)
            })
            .disposed(by: rx.disposeBag)
        
        return Output(recipeList: recipeList)
    }
    
}
