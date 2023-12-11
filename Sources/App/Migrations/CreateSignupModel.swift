import Fluent

struct CreateSignupModel: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users")
            .id()
            .field("first", .string)
            .field("last", .string)
            .field("email", .string)
            .field("password", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users").delete()
    }
}
