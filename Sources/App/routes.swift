import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req in
        return "in hello"
    }
    
    /*app.get("signup") {req in
       UserManager.signUpLogic()
    }*/
	
    try app.register(collection: TodoController())
}
