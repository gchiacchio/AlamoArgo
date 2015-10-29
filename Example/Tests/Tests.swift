import UIKit
import XCTest
import AlamoArgo
import Alamofire
import Argo

class Tests: XCTestCase {
    
    func testGETRequestDecodableResponse() {
        // Given
        let URL = "https://raw.githubusercontent.com/gchiacchio/AlamoArgo/master/userdata.json"
        let expectation = expectationWithDescription("\(URL)")
        
        var request: NSURLRequest?
        var response: NSHTTPURLResponse?
        var user: User?
        var error: NSError?
        
        let path = NSBundle(forClass: Tests.self).pathForResource("userdata", ofType: "json")
        let data : NSData! = try? NSData(contentsOfFile:path!, options: .DataReadingMappedIfSafe)
        let json : AnyObject! =   try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        
        let userJson: AnyObject? = json.valueForKeyPath("user")
        let expectedUser: User? = decode(userJson!)
        
        // When
        Alamofire.request(.GET, URL)
            .responseDecodable(keyPath: "user") { (responseU: Response<User, NSError>) in
                request = responseU.request
                response = responseU.response
                user = responseU.result.value
                error = responseU.result.error
                
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
        
        // Then
        XCTAssertNotNil(request, "request should not be nil")
        XCTAssertNotNil(response, "response should not be nil")
        XCTAssertTrue(hasValue(user), "user should not be nil")
        XCTAssertNil(error, "error should be nil")
        
        if let user = user, expectedUser = expectedUser {
            XCTAssertEqual(user.id, expectedUser.id)
        }
    }
    
    func testGETArray() {
        // Given
        let URL = "https://raw.githubusercontent.com/gchiacchio/AlamoArgo/master/userdata.json"
        let expectation = expectationWithDescription("\(URL)")
        
        var request: NSURLRequest?
        var response: NSHTTPURLResponse?
        var friends: [User]?
        var error: NSError?
        
        
        // When
        Alamofire.request(.GET, URL)
            .responseDecodable(keyPath: "user.friends") { (responseF: Response<[User], NSError>) in
                request = responseF.request
                response = responseF.response
                friends = responseF.result.value
                error = responseF.result.error
                
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
        
        // Then
        XCTAssertNotNil(request, "request should not be nil")
        XCTAssertNotNil(response, "response should not be nil")
        XCTAssertTrue(hasValue(friends), "friends should not be nil")
        XCTAssertNil(error, "error should be nil")
        
        if let friends = friends {
            XCTAssertGreaterThan(friends.count, 0)
        }
    }

    
    func hasValue<T>(value: T?) -> Bool {
        switch (value) {
        case .Some(_): return true
        case .None: return false
        }
    }
}

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
            <*> j <|| "friends" // parse arrays of objects
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
