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

extension Alamofire.Request {
    public func responseDecodable<T: Decodable where T == T.DecodedType>(keyPath: String? = nil, completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, NSError?) -> Void) -> Self {
        let serializer: Serializer = { (request, response, data) in
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (json: AnyObject?, serializationError) = JSONSerializer(request, response, data)
            var jsonForPath: AnyObject? = json
            var error = serializationError
            if keyPath != nil {
                jsonForPath = json?.valueForKeyPath(keyPath!)
                if jsonForPath == nil && error == nil {
                    error = NSError(domain: "AlamoArgoError", code: 1, userInfo: [NSLocalizedDescriptionKey:"No such path"])
                }
            }
            if response != nil && jsonForPath != nil {
                let obj: T? = decode(jsonForPath!)
                return (obj as? AnyObject, nil)
            } else {
                return (nil, error)
            }
        }
        
        return response(serializer: serializer, completionHandler: { (request, response, object, error) in
            completionHandler(request, response, object as? T, error)
        })
    }

    public func responseDecodable<T: Decodable where T == T.DecodedType>(keyPath: String? = nil, completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, NSError?) -> Void) -> Self {
        let serializer: Serializer = { (request, response, data) in
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (json: AnyObject?, serializationError) = JSONSerializer(request, response, data)
            var jsonForPath: AnyObject? = json
            var error = serializationError
            if keyPath != nil {
                jsonForPath = json?.valueForKeyPath(keyPath!)
                if jsonForPath == nil && error == nil {
                    error = NSError(domain: "AlamoArgoError", code: 1, userInfo: [NSLocalizedDescriptionKey:"No such path"])
                }
            }

            if response != nil && jsonForPath != nil {
                let obj: [T]? = decode(jsonForPath!)
                return (obj as? AnyObject, nil)

            } else {
                return (nil, error)
            }
        }
        
        return response(serializer: serializer, completionHandler: { (request, response, object, error) in
            completionHandler(request, response, object as? [T], error)
        })
    }
    
}