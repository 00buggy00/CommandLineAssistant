enum ConsoleArgumentType {
    case longOption(String)
    case shortOption(String)
    case shortOptions([String])
    case argument(String)
    
    init(value: String) throws {
        switch value.prefix(while: { $0 == "-" }) {
        case "--":
            self = .longOption(value)
        case "-":
            switch value.count {
            case 3...:
                var options = [String]()
                
                for character in value[value.index(after: value.startIndex)..<value.endIndex] {
                    options.append("-\(character)")
                }
                
                self = .shortOptions(options)
            case 2:
                self = .shortOption(value)
            default:
                throw ConsoleArgumentError.optionNotProvidedWithTag("Syntax error:  \(value) is not associated an available option")
            }
        default:
            self = .argument(value)
        }
    }
}
public indirect enum RawArgument<ArgumentType> {
    case option(ArgumentType)
    case needsValue(ArgumentType)
    case programArgument(ArgumentType)
}
public indirect enum ConsoleArgumentBlueprint<Option, Argument> {
    case link(ConsoleArgumentBlueprint, ConsoleArgumentBlueprint)
    case option(Option)
    case optionWithArgument(Option, Argument)
    case argument(Argument)
    case endOfBlueprint
}
enum ConsoleArgumentError: Error {
    case nonArgumentReturnedForArgumentTakingWrapper
    case consoleArgumentDoesNotMatchProgramAvailableInputs(String)
    case optionNotProvidedWithTag(String)
    case noArgumentProvidedForArgumentTakingOption(String)
    case unexpectedErrorReached
}
//  Users to provide an enum that conforms to ConsoleOptionsAvailable.
//  switch statesments within the initializers are used to define the
//  string representations of the enum cases (i.e. `"path"`, and `"p"`
//  assign to `case path`.
public protocol CommandLineArgumentDelegate {
    associatedtype ConsoleArgument
    
    func anaylzeCommandLineArugments() -> ConsoleArgumentBlueprint<ConsoleArgument, String>?
    func validate(rawValue: String) throws -> RawArgument<ConsoleArgument>
}
extension CommandLineArgumentDelegate {
    func anaylzeCommandLineArugments() -> ConsoleArgumentBlueprint<ConsoleArgument, String>? {
        do {
            return try formBlueprint(from: &CommandLine.arguments[CommandLine.arguments.index(after: 0)...])
        } catch ConsoleArgumentError.noArgumentProvidedForArgumentTakingOption(let message), ConsoleArgumentError.optionNotProvidedWithTag(let message), ConsoleArgumentError.consoleArgumentDoesNotMatchProgramAvailableInputs(let message) {
            print(message)
            return nil
        } catch ConsoleArgumentError.unexpectedErrorReached {
            print("An unexpected error was reached")
            return nil
        } catch {
            print("Non-ConsoleArgumentError reached.")
            return nil
        }
    }
    private func associate(_ option: String, to arguments: inout ArraySlice<String>) throws -> ConsoleArgumentBlueprint<ConsoleArgument, String> {
        switch try self.validate(rawValue: option) {
        case .needsValue(let optionNeedingValue):
            guard case .argument(let argumentToOption) = try ConsoleArgumentType(value: arguments[0]) else { throw ConsoleArgumentError.noArgumentProvidedForArgumentTakingOption("Syntax error:  \(optionNeedingValue) expects argument") }
            arguments = arguments[arguments.index(after: arguments.startIndex)...]
            return ConsoleArgumentBlueprint<ConsoleArgument, String>.optionWithArgument(optionNeedingValue, argumentToOption)
        case .option(let standAloneOption):
            return ConsoleArgumentBlueprint<ConsoleArgument, String>.option(standAloneOption)
        default:
            throw ConsoleArgumentError.unexpectedErrorReached
        }
    }
    private func formBlueprint(from arguments: inout ArraySlice<String>) throws -> ConsoleArgumentBlueprint<ConsoleArgument, String> {
        guard let argument = arguments.first else { return ConsoleArgumentBlueprint<ConsoleArgument, String>.endOfBlueprint }
        var tailArguments = arguments[arguments.index(after: arguments.startIndex)...]
        
        switch try ConsoleArgumentType(value: argument) {
        case .longOption(let option), .shortOption(let option):
            return ConsoleArgumentBlueprint<ConsoleArgument, String>.link(try associate(option, to: &tailArguments), try formBlueprint(from: &tailArguments))
        case .shortOptions(var options):
            return ConsoleArgumentBlueprint<ConsoleArgument, String>.link(try formBlueprint(from: &options[options.startIndex...]), try formBlueprint(from: &tailArguments))
        case .argument(let argument):
            return ConsoleArgumentBlueprint<ConsoleArgument, String>.link(ConsoleArgumentBlueprint<ConsoleArgument, String>.argument(argument), try formBlueprint(from: &tailArguments))
        }
    }
}

