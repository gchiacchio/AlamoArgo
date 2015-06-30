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
import Runes

/// Constant defining the domain to be set in NSError instances.
public let AlamoArgoErrorDomain = "AlamoArgo.err"

// MARK: - responseDecodable

/**
Alamofire.Request extensions to parse a JSON response into an object using Argo framework
*/
extension Request {
    
    /**
    JSON Response serializer with keyPath
    
    :param: request  The `NSURLRequest`
    :param: response The `NSHTTPURLResponse` obtained
    :param: data     Raw data in the response
    :param: keyPath  KeyPath to locate in the parsed JSON.
    
    :returns: Tuple representing the parsed result starting from **keyPath**, if present, and the corresponding error in case of any.
    */
    private func jsonResponseSerializer(request: NSURLRequest, response: NSHTTPURLResponse?, data: NSData?, keyPath: String? = nil) -> (AnyObject?, NSError?) {
        let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
        let (json: AnyObject?, serializationError) = JSONSerializer(request, response, data)
        var jsonForPath: AnyObject? = json
        var error = serializationError
        if keyPath != nil {
            jsonForPath = json?.valueForKeyPath(keyPath!)
            if jsonForPath == nil && error == nil {
                error = NSError(domain: AlamoArgoErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey:"No such path"])
            }
        }
        if response != nil && jsonForPath != nil {
            return (jsonForPath, nil)
        } else {
            return (nil, error)
        }
    }

    
    /**
    Response handler called with the `Decoded` object, or error. This is the **single object** handler
    
    :param: keyPath           KeyPath in JSON response where to start parsing to create the `Decodable` object
    :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the `Decodable` object, if one could be created from the URL response and data, and any error produced while creating the `Decodable` object.
    
    :returns: The `Request` instance.
    */
    public func responseDecodable<T: Decodable where T == T.DecodedType>(keyPath: String? = nil, completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, NSError?) -> Void) -> Self {
        let serializer: Serializer = { (request, response, data) in
            var (jsonForPath: AnyObject?, error) = self.jsonResponseSerializer(request, response: response, data: data, keyPath: keyPath)
            if let json: AnyObject = jsonForPath {
                let obj: Decoded<T> = decode(json)
                switch (obj) {
                case let .Success(x):
                    return (obj.value as? AnyObject, nil)
                default:
                    error = NSError(domain: AlamoArgoErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey:obj.description])
                }
            }
            return (nil, error)
        }
        
        return response(serializer: serializer, completionHandler: { (request, response, object, error) in
            completionHandler(request, response, object as? T, error)
        })
    }

    /**
    Response handler called with the `Decoded` object, or error. This is the **array** handler
    
    :param: keyPath           KeyPath in JSON response where to start parsing to create the `Decodable` object
    :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the `Decodable` object, if one could be created from the URL response and data, and any error produced while creating the `Decodable` object.
    
    :returns: The `Request` instance.
    */
    public func responseDecodable<T: Decodable where T == T.DecodedType>(keyPath: String? = nil, completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, NSError?) -> Void) -> Self {
        let serializer: Serializer = { (request, response, data) in
            var (jsonForPath: AnyObject?, error) = self.jsonResponseSerializer(request, response: response, data: data, keyPath: keyPath)
            if let json: AnyObject = jsonForPath {
                let obj: Decoded<[T]> = decode(jsonForPath!)
                switch (obj) {
                case let .Success(x):
                    return (obj.value as? AnyObject, nil)
                default:
                    error = NSError(domain: AlamoArgoErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey:obj.description])
                }
            }
            return (nil, error)
        }
        
        return response(serializer: serializer, completionHandler: { (request, response, object, error) in
            completionHandler(request, response, object as? [T], error)
        })
    }
}
