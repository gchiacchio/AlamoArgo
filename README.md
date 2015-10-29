# AlamoArgo

[![CI Status](http://img.shields.io/travis/Guillermo Chiacchio/AlamoArgo.svg?style=flat)](https://travis-ci.org/Guillermo Chiacchio/AlamoArgo)
[![Version](https://img.shields.io/cocoapods/v/AlamoArgo.svg?style=flat)](http://cocoapods.org/pods/AlamoArgo)
[![License](https://img.shields.io/cocoapods/l/AlamoArgo.svg?style=flat)](http://cocoapods.org/pods/AlamoArgo)
[![Platform](https://img.shields.io/cocoapods/p/AlamoArgo.svg?style=flat)](http://cocoapods.org/pods/AlamoArgo)

## Usage

###1. Create your Argo compatible model

```swift
import Argo
import Runes

class User {
    let id: Int
    let name: String
    let email: String?
    let role: RoleType
    let companyName: String
    let friends: [User]
    
    init (id: Int, name: String, email: String?, role: RoleType, companyName: String, friends: [User]) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.companyName = companyName
        self.friends = friends
    }
}

extension User: Decodable {
    static func create(id: Int)(name: String)(email: String?)(role: RoleType)(companyName: String)(friends: [User]) -> User {
        return User(id: id, name: name, email: email, role: role, companyName: companyName, friends: friends)
    }
    
    static func decode(j: JSON) -> Decoded<User> {
        return User.create
            <^> j <| "id"
            <*> j <| "name"
            <*> j <|? "email" // Use ? for parsing optional values
            <*> j <| "role" // Custom types that also conform to Decodable just work
            <*> j <| ["company", "name"] // Parse nested objects
            <*> j <|| "friends" // Parse arrays of objects
    }
}

enum RoleType: String {
    case Admin = "Admin"
    case User = "User"
}

extension RoleType: Decodable {
    static func decode(j: JSON) -> Decoded<RoleType> {
        switch j {
        case let .String(s): return .fromOptional(RoleType(rawValue: s))
        default: return .Failure(.TypeMismatch(expected: "String", actual: "\(j)")) // Provide an Error message for a string type mismatch
        }
    }
}
```

###2. Requesting the entity
**keyPath** parameter allows to selectively parse a particular object inside JSON response. Default value is nil.

```swift
import AlamoArgo
import Alamofire

let URL = "https://raw.githubusercontent.com/gchiacchio/AlamoArgo/master/userdata.json"
Alamofire.request(.GET, URL)
	.responseDecodable(keyPath: "user") { 
	(response: Response<User, NSError>) in
	if let user = response.result.value {
		print(user)	}
}
```
###3. Requesting friends array
**keyPath** parameter allows to selectively parse a particular object inside JSON response. Default value is nil.

```swift
import AlamoArgo
import Alamofire

let URL = "https://raw.githubusercontent.com/gchiacchio/AlamoArgo/master/userdata.json"
Alamofire.request(.GET, URL)
	.responseDecodable(keyPath: "user.friends") { 
	(response: Response<[User], NSError>) in
	if let friends = response.result.value {
		print(friends)	}
}
```

## Requirements

- iOS 8.0+ / Mac OS X 10.9+
- Xcode 7
- Swift 2

Note: For Swift 1.2 use version 0.3.0

## Installation

AlamoArgo is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AlamoArgo"
```

## Author

Guillermo Chiacchio, guillermo.chiacchio@gmail.com

## License

AlamoArgo is available under the MIT license. See the LICENSE file for more info.
