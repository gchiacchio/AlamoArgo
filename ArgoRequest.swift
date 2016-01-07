//
//  ArgoRequest.swift
//  Pods
//
//  Created by Guillermo Chiacchio on 6/24/15.
//
//

import Foundation
import Alamofire
import Argo

/// Constant defining the domain to be set in NSError instances.
public let AlamoArgoErrorDomain = "AlamoArgo.err"

// MARK: - responseDecodable

/**
Alamofire.Request extensions to parse a JSON response into an object using Argo framework
*/
extension Request {
    
    /**
    JSON Response serializer with keyPath
    
    - parameter request:  The `NSURLRequest`
    - parameter response: The `NSHTTPURLResponse` obtained
    - parameter data:     Raw data in the response
    - parameter keyPath:  KeyPath to locate in the parsed JSON.
    
    - returns: Tuple representing the parsed result starting from **keyPath**, if present, and the corresponding error in case of any.
    */
    public static func jsonResponseSerializer(keyPath: String? = nil) -> ResponseSerializer<AnyObject, NSError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            
            let result: Result<AnyObject, NSError> = JSONSerializer.serializeResponse(request, response, validData, error)
            
            var jsonForPath: AnyObject? = result.value
            
            if let myError = result.error {
                return .Failure(myError)
            }
            
            if let kp = keyPath {
                jsonForPath = result.value?.valueForKeyPath(kp)
                if let jsonResult = jsonForPath {
                    return .Success(jsonResult)
                } else {
                    return .Failure(NSError(domain: AlamoArgoErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey:"No such path"]))
                }
            }
            
            if let jsonResult = jsonForPath {
                return .Success(jsonResult)
            }
            
            return .Failure(NSError(domain: AlamoArgoErrorDomain, code: 1, userInfo: [:]))
            
        }
    }
    
    /**
    Response handler called with the `Decoded` object, or error. This is the **single object** handler
    
    - parameter queue:              The queue on which the completion handler is dispatched.
    - parameter keyPath:           KeyPath in JSON response where to start parsing to create the `Decodable` object
    - parameter completionHandler: A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the `Decodable` object, if one could be created from the URL response and data, and any error produced while creating the `Decodable` object.
    
    - returns: The `Request` instance.
    */
    public func responseDecodable<T: Decodable where T == T.DecodedType>(queue queue: dispatch_queue_t? = nil, keyPath: String? = nil, completionHandler: Response<T, NSError> -> Void) -> Self {
        let serializer = ResponseSerializer<T, NSError> { request, response, data, error in
            if let myError = error {
                return Result<T, NSError>.Failure(myError)
            }
            let result: Result<AnyObject, NSError> = Request.jsonResponseSerializer(keyPath).serializeResponse(request, response, data, error)
            if let myError = error {
                return Result<T, NSError>.Failure(myError)
            }
            if let myError = result.error {
                return Result<T, NSError>.Failure(myError)
            }
            if let json: AnyObject = result.value {
                let obj: Decoded<T> = decode(json)
                switch (obj) {
                case let .Success(value):
                    return Result<T, NSError>.Success(value)
                default:
                    return Result<T, NSError>.Failure(NSError(domain: AlamoArgoErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey:obj.description]))
                }
            }
            return Result<T, NSError>.Failure(NSError(domain: AlamoArgoErrorDomain, code: -1, userInfo: nil))
        }
        
        return response(queue: queue, responseSerializer: serializer, completionHandler: completionHandler)
    }

    /**
    Response handler called with the `Decoded` object, or error. This is the **array** handler

    - parameter queue:              The queue on which the completion handler is dispatched.
    - parameter keyPath:           KeyPath in JSON response where to start parsing to create the `Decodable` object
    - parameter completionHandler: A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the `Decodable` object, if one could be created from the URL response and data, and any error produced while creating the `Decodable` object.
    
    - returns: The `Request` instance.
    */
    public func responseDecodable<T: Decodable where T == T.DecodedType>(queue queue: dispatch_queue_t? = nil, keyPath: String? = nil, completionHandler: Response<[T], NSError> -> Void) -> Self {
        let serializer = ResponseSerializer<[T], NSError> { request, response, data, error in
            if let myError = error {
                return Result<[T], NSError>.Failure(myError)
            }
            let result: Result<AnyObject, NSError> = Request.jsonResponseSerializer(keyPath).serializeResponse(request, response, data, error)
            if let myError = error {
                return Result<[T], NSError>.Failure(myError)
            }
            if let myError = result.error {
                return Result<[T], NSError>.Failure(myError)
            }
            if let json: AnyObject = result.value {
                let obj: Decoded<[T]> = decode(json)
                switch (obj) {
                case let .Success(value):
                    return Result<[T], NSError>.Success(value)
                default:
                    return Result<[T], NSError>.Failure(NSError(domain: AlamoArgoErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey:obj.description]))
                }
            }
            return Result<[T], NSError>.Failure(NSError(domain: AlamoArgoErrorDomain, code: -1, userInfo: nil))
        }
        
        return response(queue: queue, responseSerializer: serializer, completionHandler: completionHandler)
    }
}
