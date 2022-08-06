//
//  Receipe.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/5/22.
//

import Foundation
import RealmSwift
import Realm
import RxSwift

final class Recipe: Object {
    
    @objc dynamic var id: Int = 0 //primary key
    @objc dynamic var title: String?
    @objc dynamic var type: String?
    @objc dynamic var ingrediant: String?
    @objc dynamic var dateTime: Date?
    //@objc dynamic var receipeImageUrl: String?
    @objc dynamic var receipeImageData: Data? = nil
    @objc dynamic var steps: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func incrementID() -> Int {
        return (RealmManager.shared.realm.objects(Recipe.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    func getAllRecipe() -> Results<Recipe> {
        let result = RealmManager.shared.realm.objects(Recipe.self)
        return result
    }
    
    func deleteRecipe(id: Int) {
        let predicate = NSPredicate(format: "id == %ld", id)
        if let recipe = RealmManager.shared.realm.objects(Recipe.self).filter(predicate).first {
            RealmManager.shared.delete([recipe])
        }
    }
    
    func getCurrentRecipe(id: Int) -> Results<Recipe> {
        let predicate = NSPredicate(format: "id == %ld", id)
        return RealmManager.shared.realm.objects(Recipe.self).filter(predicate)
    }
    
    func getRecipe(id: Int, realm: Realm? = RealmManager.shared.realm) -> Recipe? {
        let predicate = NSPredicate(format: "id == %ld", id)
        return realm?.objects(Recipe.self).filter(predicate).first
    }
    
}
