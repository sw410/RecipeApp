//
//  RealmManager.swift
//  AIChat
//
//  Created by Kenneth Lee on 02/12/2019.
//  Copyright © 2019 AIChat. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm
import Realm

let backgroundQueue = DispatchQueue(label: "background", qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)

class RealmManager: NSObject {
    
    static let shared = RealmManager()
    var configuration: Realm.Configuration? = nil
    private var scheduler: RunLoopThreadScheduler? = nil
    let currentSchemaVersion = 7
    
    var realm: Realm {
        return try! Realm(configuration: self.configuration!)
    }
    
    override init() {
        super.init()
        //        if let url = Constant.getFromBackupRealmPath(), Constant.getIsFromBackupRealm() {
        //            self.configuration = Realm.Configuration(fileURL: url)
        //            print("File 📁 url: \(RLMRealmPathForFile(url.lastPathComponent))")
        //        } else {
        //            self.configuration = Realm.Configuration()
        //        }
        
        self.handleMigration()
        
        let name = "receipeapp"
        self.scheduler = RunLoopThreadScheduler(threadName: name)
        
        print("File 📁 url: \(RLMRealmPathForFile("default.realm"))")
    }
    
    func handleMigration() {
        
        self.configuration = Realm.Configuration(schemaVersion: UInt64(currentSchemaVersion), migrationBlock: { (migration, oldVersion) in
            
            if oldVersion < 1 {
                
            }
            
        }, deleteRealmIfMigrationNeeded: false)
        
    }
    
    func updateRealmFile(url: URL) {
        configuration = Realm.Configuration(fileURL: url)
    }
    
    func retrieveAllDataForObject(_ T : Object.Type) -> [Object] {
        
        var objects = [Object]()
        for result in realm.objects(T) {
            objects.append(result)
        }
        return objects
    }
    
    func deleteAllDataForObject(_ T : Object.Type) {
        
        self.delete(self.retrieveAllDataForObject(T))
    }
    
    func replaceAllDataForObject(_ T : Object.Type, with objects : [Object]) {
        
        deleteAllDataForObject(T)
        add(objects)
    }
    
    func add(_ objects : [Object], completion : @escaping() -> ()) {
        
        try? realm.safeWrite {
            realm.add(objects, update: .modified)
            completion()
        }
    }
    
    func add(_ objects : [Object]) {

        try? realm.safeWrite {
            realm.add(objects, update: .modified)
        }
        
    }
    
    func update(_ block: @escaping ()->Void) {
        try? realm.safeWrite(block)
    }
    
    func delete(_ objects : [Object]) {
        
        try? realm.safeWrite {
            realm.delete(objects)
        }
        
    }
    
    func updateFieldAsync<T>(callback: @escaping (T) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let realm = try! Realm()
            if let objectToUpdate = realm.object(ofType: T.self as! Object.Type, forPrimaryKey: 1) {
                try! realm.write {
                    callback(objectToUpdate as! T)
                }
            }
        }
    }
    
}



extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}
