import XCTest
@testable import CommandLineAssistant

final class CommandLineAssistantTests: XCTestCase {
    
    struct FooConsoleArgument: CommandLineArgumentDelegate {
        typealias ConsoleArgument = FooOptions
        
        enum FooOptions {
            case path
        }
        
        func validate(rawValue: String) throws -> RawArgument<ConsoleArgument> {
            switch rawValue {
            case "-f", "--foo":
                return RawArgument.needsValue(ConsoleArgument.path)
            default:
                throw ConsoleArgumentError.consoleArgumentDoesNotMatchProgramAvailableInputs("\(rawValue) is not an available option")
            }
        }
    }
    
}
