
import Vapor
import NIOSSL

let app = Application()
let numbers = ["1","2","3","4","5","6","7","8","9","0"]
let uppercase = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
let lowercase = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
let special = ["!","@","#","$","%","^","&","*","(",")"]
let tlds = [".com", ".org", ".co", ".net", ".gov", ".info", ".biz"]


final class UserManager {
    static func signUpLogic() -> String {
        // Your logic for signup goes here
        return "sign up"
    }
}


struct YourData: Content {
      let first: String
      let last: String
      let email: String
      let password: String
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
    for t in tlds {
       if em.contains(String(t)){
          myintchk += 1
       }       
    }
    
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
    var spsh = 0
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

       else if special.contains(String(p)) {
          spsh += 1
       }

       else if numbers.contains(String(p)) {
          num += 1
       }

    }

    if spsh > 0 && num > 0 && low > 0 && up > 0 {
       ret = 1
    }

    else { 
       ret = 0
    }

    return ret
}

/*
func signUpDatabaseReq() -> EventLoopFuture<String> {

}*/


func handleSignUpPostRequest(req: Request) throws -> EventLoopFuture<String> {
    let data = try req.content.decode(YourData.self)
    print("first_name: \(data.first),  last_name: \(data.last), email: \(data.email), password: \(data.password)")
    var myreturn : EventLoopFuture<String> = req.eventLoop.makeSucceededFuture("success")
    let fnamecheck = serversidenamecheck(name: data.first)
    let lnamecheck = serversidenamecheck(name: data.last)
    let tldchkint = tldcheck(em: data.email)
    let status = hostcheck(em: data.email, chr: "@")
    let pwcheck = passwordcheck(pw: data.password)


    //let error = Abort(.badRequest, reason: "Last name changed in transit, resubmit signup form")
    //return req.eventLoop.makeFailedFuture(error)

    //server side validation
    if data.first.count == 0 {
      let error = Abort(.badRequest, reason: "first name changed in transit, resubmit signup form")
      myreturn = req.eventLoop.makeFailedFuture(error)
    }

    else if fnamecheck == 0 {
      let error = Abort(.badRequest, reason: "first name changed in transit, resubmit signup form")
      myreturn = req.eventLoop.makeFailedFuture(error)
    }

    else if lnamecheck == 0 {
      let error = Abort(.badRequest, reason: "last name changed in transit, resubmit signup form")
      myreturn = req.eventLoop.makeFailedFuture(error)
    }

    else if data.last.count == 0 {
      let error = Abort(.badRequest, reason: "last name changed in transit, resubmit signup form")
      myreturn = req.eventLoop.makeFailedFuture(error)
    }

    else if data.email.count == 0 {
      let error = Abort(.badRequest, reason: "email was changed in transit, resubmit signup form")
      myreturn = req.eventLoop.makeFailedFuture(error)  
    }

    else if !data.email.contains("@") {
      let error = Abort(.badRequest, reason: "email was changed in transit, resubmit signup form")
      myreturn = req.eventLoop.makeFailedFuture(error)
    }
    
    else if tldchkint != 1 {
      let error = Abort(.badRequest, reason: "email was changed in transit, resubmit signup form")
      myreturn = req.eventLoop.makeFailedFuture(error)
    }
    
    else if status != 1 {
      let error = Abort(.badRequest, reason: "email was changed in transit, resubmit signup form")
      myreturn = req.eventLoop.makeFailedFuture(error)
    }
    
    else if pwcheck != 1 {
      let error = Abort(.badRequest, reason: "email was changed in transit, resubmit signup form")
      myreturn = req.eventLoop.makeFailedFuture(error)
    }

    else {
      myreturn = req.eventLoop.makeSucceededFuture("success")
    } 

    return myreturn
}

app.get { req in
    return "Hello, Vapor"
}

app.get("hello") {req in 
   return "in hello"
}

app.get("signup") {req in
   UserManager.signUpLogic()
}

app.post("signup", use: handleSignUpPostRequest)

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
