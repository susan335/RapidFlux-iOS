//
//  ViewModel.swift
//  RapidFlux
//
//  Created by Yohta Watanave on 2020/02/27.
//

import Foundation
import RxSwift

private var currentStateKey = "currentState"
private var stateKey = "state"
private var disposeBagKey = "disposeBag"
private var dispatcherKey = "dispatcher"
private var stubKey = "stub"
private var stateSubjectKey = "stateSubject"
private var errorTranslatorKey = "errorTranslatorKey"

public protocol ViewModel: class, AssociatedObjectStore {
    associatedtype Action
    associatedtype State
    
    var disposeBag: DisposeBag { get }
    var dispatcher: PublishSubject<Action> { get }
    var initialState: State { get }
    var currentState: State { get }
    var errorTranslator: ErrorTranslator { get }
    var state: Observable<State> { get }
    func reducer(state: State, action: Action) -> State
}

extension ViewModel {
    
    public var disposeBag: DisposeBag {
        return self.associatedObject(forKey: &disposeBagKey, default: DisposeBag())
    }
    
    public private(set) var currentState: State {
        get {
            return self.associatedObject(forKey: &currentStateKey, default: self.initialState)
        }
        set {
            self.setAssociatedObject(newValue, forKey: &currentStateKey)
        }
    }
    
    public var dispatcher: PublishSubject<Action> {
        return self.associatedObject(forKey: &dispatcherKey, default: PublishSubject<Action>.init())
    }
    
    public var state: Observable<State> {
        return self.associatedObject(forKey: &stateKey, default: self.createDefaultStream())
    }
    
    public var stateSubject: BehaviorSubject<State> {
        get {
            return self.associatedObject(forKey: &stateSubjectKey, default: BehaviorSubject<State>(value: self.initialState))
        }
        set {
            self.setAssociatedObject(newValue, forKey: &stateSubjectKey)
        }
    }
    
    public var isStubEnable: Bool {
        get {
            return self.associatedObject(forKey: &stubKey, default: false)
        }
        set {
            self.setAssociatedObject(newValue, forKey: &stubKey)
        }
    }
    
    private func createDefaultStream() -> Observable<State> {
        if self.isStubEnable {
            return self.stateSubject
                .do(onNext: { [weak self] state in
                    self?.currentState = state
                })
        }
        let state = self.dispatcher
            .scan(self.initialState) { [weak self] state, action -> State in
                guard let `self` = self else { return state }
                return self.reducer(state: state, action: action)
            }
            .observeOn(MainScheduler.instance)
            .startWith(self.initialState)
            .do(onNext: { [weak self] state in
                self?.currentState = state
            })
            .replay(1)
        state.connect().disposed(by: self.disposeBag)
        return state
    }
}

public protocol AutoGenerateViewModel: ViewModel {}
