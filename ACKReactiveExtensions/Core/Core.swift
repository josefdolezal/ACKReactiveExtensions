//
//  Core.swift
//  Pods
//
//  Created by Jan Mísař on 04.06.16.
//
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Result

//MARK: ReactiveCocoa

extension SignalProducerProtocol {
    
    /// Ignore errors and return SignalProducer that completes instead of error
    public func ignoreError() -> SignalProducer<Value, NoError> {
        return flatMapError { _ in .empty }
    }
}

/// Merge array of producers to a single SignalProducer
@available(*, deprecated, message: "Use native SignalProducer.merge()")
public func merge<T, E>(signals: [SignalProducer<T, E>]) -> SignalProducer<T, E> {
    let producers = SignalProducer<SignalProducer<T, E>, E>(signals)
    return producers.flatten(.merge)
}

extension SignalProducerProtocol where Value == Void, Error == NoError {
    /// Perform side effect
    public static func sideEffect(actions: @escaping () -> ()) -> SignalProducer<(), NoError> {
        return SignalProducer<(), NoError> { sink, _ in
            actions()
            sink.sendCompleted()
        }
    }
}

extension SignalProducer {
    /**
     * Lazily evaluate a closure when SignalProducer starts
     *
     * The autoclosure can still retain self strongly. The compiler will warn you by requiring `self.`.
     * Dont ignore memory managment! 
     * If you need to capture self weekly (or unowned), you can't use autoclosure and must supply a full closure.
     *
     * - parameter lazyValue: Closure to be evaluated
     */
    public init(lazyValue: @autoclosure @escaping () -> Value) {
        self.init { observer, _ in
            observer.send(value: lazyValue())
            observer.sendCompleted()
        }
    }
}

//MARK: Disposing

private struct AssociationKey {
    static var lifecycleObject: UInt8 = 1
}

/**
 * Protocol that allows various objects to take advantage of reactive.lifetime signal
 */
public protocol Disposing: class { }

extension Disposing {
    fileprivate var lifecycleObject: NSObject {
        return lazyAssociatedProperty(self, &AssociationKey.lifecycleObject, factory: {
            NSObject()
        })
    }
}

extension Reactive where Base: Disposing {
    /**
     * Lifetime of object
     */
    public var lifetime: Lifetime {
        return base.lifecycleObject.reactive.lifetime
    }
}

//MARK: Associated properties

/**
 * Create associated property with given host.
 * Subsequent calls with the same host and key return the same associated objects.
 *
 * - parameter host: Host of the newly created property
 * - parameter key: Key with which the newly created property will be associated with
 * - parameter factory: Factory that actually creates the object to be associated
 * - returns: Newly created property
 */
public func lazyAssociatedProperty<T: Any>(_ host: Any, _ key: UnsafeRawPointer, factory: () -> T) -> T {
    var associatedProperty = objc_getAssociatedObject(host, key) as? T

    if associatedProperty == nil {
        associatedProperty = factory()
        objc_setAssociatedObject(host, key, associatedProperty, .OBJC_ASSOCIATION_RETAIN)
    }
    return associatedProperty!
}

/**
 * Create associated mutable property with given host.
 * Subsequent calls with the same host and key return the same associated objects.
 *
 * - parameter host: Host of the newly created property
 * - parameter key: Key with which the newly created property will be associated with
 * - parameter setter: Setter that will propagate new values to the newly created property
 * - parameter getter: Getter that will read initial value
 * - returns: Newly created MutableProperty
 */
public func lazyMutableProperty<T>(_ host: AnyObject, _ key: UnsafeRawPointer, _ setter: @escaping (T) -> (), _ getter: () -> T) -> MutableProperty<T> {
    return lazyAssociatedProperty(host, key) {
        let property = MutableProperty<T>(getter())
        property.producer
            .startWithValues { setter($0) }
        return property
    }
}
