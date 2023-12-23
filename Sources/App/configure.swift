import NIOSSL
import Fluent
import FluentMySQLDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.mysql(
        hostname: "randaalhajali.com",
        port: 3306,
        username: "myuser",
        password: "Mypass123",
        database: "mydb",
        tlsConfiguration: .forClient(certificateVerification: .none),
        maxConnectionsPerEventLoop: 1,
        connectionPoolTimeout: .seconds(70)  // Adjust this value
    ), as: .mysql)

    app.migrations.add(CreateTodo())

    app.views.use(.leaf)

    app.migrations.add(CreateSignupModel())    
    //app.migrations.app(signupmodel)    

    // register routes
    try routes(app)
}
