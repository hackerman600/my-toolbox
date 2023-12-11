import Vapor
import FluentMySQLDriver
import Fluent

final class signupmodel: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "first")
    var first: String

    @Field(key: "last")
    var last: String

    @Field(key: "email")
    var email: String

    @Field(key: "password")
    var password: String

    init() {}

    init(id: UUID? = nil, first: String, last: String, email: String, password: String){
       self.id = id 
       self.first = first
       self.last = last
       self.email = email
       self.password = password
    }

} 
