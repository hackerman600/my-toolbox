@preconcurrency
import Vapor
import NIOSSL
import Fluent
import FluentKit

let app = Application()

try configure(app)

let numbers = ["1","2","3","4","5","6","7","8","9","0"]
let uppercase = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
let lowercase = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
//let special = ["!","@","#","$","%","^","&","*","(",")"]
let tlds = ["com", "org", "co", "net", "gov", "info", "biz"]


struct MyData: Content {
    let email: String
    let password: String
}


struct MyEmail: Content {
    let email: String
}

struct Myup: Content {
    let email: String
    let target: String
    let type: String
}

func myforgothandler(req: Request) throws -> EventLoopFuture<String> {
    
      let data = try req.content.decode(MyEmail.self)

      let EmailToCheck = data.email
      
      print("email received is: ", EmailToCheck)
     
      return signupmodel.query(on: req.db)
        .filter(\.$email, .equal, EmailToCheck)
        .first()
        .flatMap { myf in
            if let myf = myf {
               //send email

               return req.eventLoop.makeSucceededFuture("user exists")
            }

            else {
               return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "email not found"))
            }
        }
    
    
}


func serversidenamecheck(name: String) -> Int {
    var myi = 0
    var stat = 0    

    for chrs in name {
       if uppercase.contains(String(chrs)) || lowercase.contains(String(chrs)) {
          myi += 1
       }
    }

    if myi == name.count {
       stat = 1
    }

    else {
       stat = 0
    }

    return stat
}


func tldcheck(em: String) -> Int {
    
    var myintchk = 0

    var domain = em.components(separatedBy: String("@"))[1]
    var t = em.components(separatedBy: String("."))
    if tlds.contains(String(t[1])){
       myintchk += 1
    }
    
    print("tld checking", t[0], " ", t[1])

    return myintchk

}

func hostcheck(em: String, chr: Character) -> Int {
   let parts = em.components(separatedBy: String(chr))
   if parts.count == 2 {
     return 1
   }
   else {
     return 0
   }
   
}


func passwordcheck(pw: String) -> Int {
    var num = 0
    var low = 0 
    var up = 0
    var ret = 0

    for p in pw {
       if lowercase.contains(String(p)) {
          low += 1
       }
       
       else if uppercase.contains(String(p)) {
          up += 1
       }

       else if numbers.contains(String(p)) {
          num += 1
       }

    }

    if num > 0 && low > 0 && up > 0 {
       ret = 1
    }

    else { 
       ret = 0
    }

    return ret
}


struct YourData: Content {
    let first: String
    let last: String
    let email: String
    let password: String
}


func loginHandler(req: Request) throws -> EventLoopFuture<String> {
    let data = try req.content.decode(MyData.self)
    
    let emailToCheck = String(data.email)
    let passwdToCheck = String(data.password)    

    print("emailToCheck = ", emailToCheck)
    print("passwdToCheck = ", passwdToCheck)
    //apply the same hash mechanisim to pw    

    return signupmodel.query(on: req.db)
        .filter(\.$email, .equal, emailToCheck)
        .filter(\.$password, .equal, passwdToCheck)
        .first()
        .flatMap { user in 
          if let user = user { 
             let myretvalue = "\(user.first):\(user.last)$\(user.email)/\(user.password)"
             return req.eventLoop.makeSucceededFuture(myretvalue)
          } 
          
          else {
             return req.eventLoop.makeSucceededFuture("")
          }

        }
    
}


func signupHandler(req: Request) throws -> EventLoopFuture<String> {
 
    let data = try req.content.decode(YourData.self)
    print("email is: ", data.email)

    let emailToCheck = String(data.email)
    //let emailToCheck = "m@y.com" // Replace with the actual email to check

    return signupmodel.query(on: req.db)
        .filter(\.$email, .equal, emailToCheck)
        .first()
        .flatMap { existingUser in
            if let myuserz = existingUser {
                print("myuserz are: ", myuserz)
                print("existing user is: ", existingUser)
                // Email already exists, handle accordingly
                return req.eventLoop.makeSucceededFuture("Email already exists")
            } else {

                let fnamecheck = serversidenamecheck(name: String(data.first))
                let lnamecheck = serversidenamecheck(name: String(data.last))
                let tldchkint = tldcheck(em: data.email)
                let status = hostcheck(em: data.email, chr: "@")
                let pwcheck = passwordcheck(pw: data.password)


                print("fname is: ", fnamecheck)
                print("lname is: ", lnamecheck)
                print("tldchkint is: ", tldchkint)
                print("status is: ", status)
                print("pwcheck is: ", pwcheck)



                // Email doesn't exist, proceed with signup logic
                if data.first.count == 0 { 
                  return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "first name was altered in transit, try again"))
                }                

                else if fnamecheck == 0 {
                  return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "first name was altered in transit, try again"))
                }

                else if data.last.count == 0 {
                  return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "last name was altered in transit, try again"))
                }                

                else if lnamecheck == 0 {
                  return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "last name was altered in transit, try again"))
                }

                else if data.email.count == 0 {
                  return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "email was altered in transit, try again"))
                }

                else if !data.email.contains("@") {
                  return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "email was altered in transit, try again"))       
                }

                else if tldchkint == 0 {
                  return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "email was altered in transit, try again"))       
                }                

                else if status != 1 {
                  return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "email was altered in transit, try again"))       
                }

                else if pwcheck != 1 { 
                  return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "passwork was altered in transit, try again"))
                }
                
                let newUser = signupmodel(first: data.first, last: data.last, email: emailToCheck, password: data.password)
                return newUser.save(on: req.db).map {                    
                  return "User signed up successfully"
                }
            }
        }
}


func handlechangeprofile(req: Request) throws -> EventLoopFuture<String> {
    let data = try req.content.decode(Myup.self)
    let emailtocheck = data.email
    let target = data.target
    let type = data.type

    print("email to check is \(emailtocheck)")
    print("trget to check is \(target)")
    print("type to check is \(type)")

    return signupmodel.query(on: req.db)
        .filter(\.$email, .equal, emailtocheck)
        .first()
        .flatMap { user in
            if let user = user {
                print("in if let user = user")

                if type == "email" {
                    user.email = target
                }

                if type == "password" {
                    user.password = target
                }

                if type == "fname" {
                    user.first = target
                }

                if type == "lname" {
                    user.last = target
                }

                return user.update(on: req.db).map { _ in
                    return "update successful"
                }

            }

            else {
                return req.eventLoop.makeSucceededFuture("update unsuccessful")
            }

        }
}



app.get("explore") {req -> String in 
        return "explore"
}

app.post("signup") {req -> EventLoopFuture<String> in
    return try signupHandler(req: req)
}

app.post("login") {req -> EventLoopFuture<String> in 
    return try loginHandler(req: req)
}

app.post("forgot") {req -> EventLoopFuture<String> in
    return try myforgothandler(req: req)
}

/*app.post("changeprofile") {
    print("change profile")
}*/

app.get("changeprofile") {req -> String in 
    return "changeprofile"
}


app.post("changeprofile") {req -> EventLoopFuture<String> in 
    return try handlechangeprofile(req: req)
}


// Use the provided certificate and private key paths
let certPath = "/etc/letsencrypt/live/randaalhajali.com/fullchain.pem"
let keyPath = "/etc/letsencrypt/live/randaalhajali.com/privkey.pem"

try app.http.server.configuration.tlsConfiguration = .forServer(
    certificateChain: NIOSSLCertificate.fromPEMFile(certPath).map { .certificate($0) },
    privateKey: .file(keyPath)
)

// Set the bind address and port in server configuration
app.http.server.configuration.hostname = "0.0.0.0"
app.http.server.configuration.port = 443

try app.run()
