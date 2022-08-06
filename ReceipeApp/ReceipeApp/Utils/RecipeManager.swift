//
//  ReceipeManager.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/5/22.
//

import Foundation
import RxSwift
import RxCocoa
import AEXML

class RecipeManager: NSObject {
    
    static let shared = RecipeManager()
    let recipeTypeList = BehaviorRelay<[String]>.init(value: [])
    
    func fetchReceipeList() {
        
        guard let xmlPath = Bundle.main.path(forResource: "recipetypes", ofType: "xml"), let data = try? Data(contentsOf: URL(fileURLWithPath: xmlPath)) else { return }

        do {
            let xmlDoc = try AEXMLDocument(xml: data, options: .init())
            
            if let recipe = xmlDoc.root["recipetypes"]["type"].all {
                var list: [String] = []
                for item in recipe {
                    list.append(item.value ?? "")
                }
                self.recipeTypeList.accept(list)
            }
        } catch {
            print(error)
        }
    }
    
    func populateDummyData() {
        
        var dummyList: [RecipeModel] = []
        dummyList.append(RecipeModel(
            image: R.image.tiramisu() ?? UIImage(),
            name: "Tiramisu",
            type: "Dessert",
            ingredients: "4 large egg yolks\n½ cup/100 grams granulated sugar, divided\n¾ cup heavy cream\n1 cup/227 grams mascarpone (8 ounces)",
            steps: "Step 1\nUsing an electric mixer in a medium bowl, whip together egg yolks and 1/4 cup/50 grams sugar until very pale yellow and about tripled in volume. A slight ribbon should fall from the beaters (or whisk attachment) when lifted from the bowl. Transfer mixture to a large bowl, wiping out the medium bowl used to whip the yolks and set aside.\n\nStep 2\n In the medium bowl, whip cream and remaining 1/4 cup/50 grams sugar until it creates soft-medium peaks. Add mascarpone and continue to whip until it creates a soft, spreadable mixture with medium peaks. Gently fold the mascarpone mixture into the sweetened egg yolks until combined.")
        )
        dummyList.append(RecipeModel(
            image: R.image.coke() ?? UIImage(),
            name: "Virgin Coke Rum",
            type: "Beverages",
            ingredients: "2 oz – Lyre’s Dark Cane Spirit Non-Alcoholic Rum\n4 oz – Coke (or Coke Zero/Diet Coke for a low-calorie mocktail)\nIce\nLime for Garnish",
            steps: "Fill glass ¾ full with ice\nPour in Lyre’s Dark Cane Spirit Non-Alcoholic Rum\nPour in Coke\nAdd lime wedge for garnish")
        )
        
        for item in dummyList {
            
            let recipe = Recipe()
            recipe.id = Recipe().incrementID()
            recipe.title = item.name
            recipe.dateTime = Date()
            recipe.type = item.type
            recipe.ingrediant = item.ingredients
            recipe.steps = item.steps
            
            if let imageData = item.image.jpegData(compressionQuality: 0.7) {
                recipe.receipeImageData = imageData
            }
            
            RealmManager.shared.add([recipe])
            
        }
        
        Constant.setIsFirstTimeLoad(true)
        
    }
    
}
