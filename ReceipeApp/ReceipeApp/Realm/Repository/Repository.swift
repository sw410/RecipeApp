//
//  Repository.swift
//  AIChat
//
//  Created by Kenneth Lee on 02/12/2019.
//  Copyright © 2019 AIChat. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import RxSwift
import RxRealm

protocol AbstractRepository {
    associatedtype T
    func queryAll() -> Observable<[T]>
    func query(with predicate: NSPredicate,
               sortDescriptors: [NSSortDescriptor]) -> Observable<[T]>
    func save(entity: T) -> Observable<Void>
    func delete(entity: T) -> Observable<Void>
    func saveUpdate(entity: T) -> Observable<Void>
    func queryOnlyOne(with predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]) -> Maybe<T>
    
    func save(entities: [T]) -> Observable<Void>
    }

final class Repository<T:RealmRepresentable>: AbstractRepository where T == T.RealmType.DomainType, T.RealmType: Object {

    private let configuration: Realm.Configuration
    private let scheduler: RunLoopThreadScheduler
    
    private var realm: Realm {
        return try! Realm(configuration: self.configuration)
    }
    
    init(configuration: Realm.Configuration) {
        self.configuration = configuration
        let name = "fple.AIChat.RealmPlatform.Repository"
        self.scheduler = RunLoopThreadScheduler(threadName: name)
        
        print("File 📁 url: \(RLMRealmPathForFile("default.realm"))")
    }
    
    func queryAll() -> Observable<[T]> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(T.RealmType.self)
            
            return Observable.array(from: objects)
                .mapToDomain()
            }
            .subscribeOn(scheduler)
    }
    
    func query(with predicate: NSPredicate,
               sortDescriptors: [NSSortDescriptor] = []) -> Observable<[T]> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(T.RealmType.self)
                                        .filter(predicate)
                                        .sorted(by: sortDescriptors.map(SortDescriptor.init))
            
            return Observable.array(from: objects)
                .mapToDomain()
            }
            .subscribeOn(scheduler)
    }
    func queryOnlyOne(with predicate: NSPredicate,
               sortDescriptors: [NSSortDescriptor] = []) -> Maybe<T> {
        return Maybe<T>.create(subscribe: { (obsever) -> Disposable in
            let realm = self.realm
            let object = realm.objects(T.RealmType.self)
                .filter(predicate)
                .sorted(by: sortDescriptors.map(SortDescriptor.init)).first

            guard let value = object else {
                obsever(.completed)
                return Disposables.create()
            }
            obsever(MaybeEvent<T>.success(value.asDomain()))
            
            return Disposables.create()
        }).subscribeOn(scheduler)
    }
    
    func saveIfNot(entity: T) -> Completable {
        return Completable.create(subscribe: {[weak self] (observer) -> Disposable in
            guard let  `self` = self else {
                return Disposables.create()
            }
           return self.realm.rx.save(entity: entity).subscribeOn(self.scheduler).subscribe()
        })
    }
    
    

    func save(entity: T) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.save(entity: entity)
            }.subscribeOn(scheduler)
    }
    
    func delete(entity: T) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.delete(entity: entity)
            }.subscribeOn(scheduler)
    }
    
    func saveUpdate(entity: T) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.save(entity: entity, update: true)
            }.subscribeOn(scheduler)
    }
    
    func save(entities: [T]) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.save(entities: entities, update: true)
            }.subscribeOn(scheduler)
    }

}
