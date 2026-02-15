import Foundation
typealias Text = NSMutableAttributedString

class ValidationError: Error {
    var message: Text
    
    init(_ message: Text) {
        self.message = message
    }
}

protocol ValidatorConvertible {
    func validated(_ value: String) throws -> Text
}

enum ValidatorType {
    case email
    case password(_ field: String)
    case requiredField(_ field: String)
    case charCount(_ min: Int?,_ max: Int?, field: String)
    case numberField(_ field: String)
    case date(formatter: DateFormatter, field: String)
}

enum VaildatorFactory {
    static func validatorFor(type: ValidatorType) -> ValidatorConvertible {
        switch type {
        case .email: return EmailValidator()
        case .password(let field): return PasswordValidator(field)
        case .requiredField(let field): return RequiredFieldValidator(field)
        case .charCount(let min, let max, let field): return CharCountValidator(min, max, fieldName: field)
        case .numberField(let field): return NumberValidator(field)
        case .date(let formatter, let field): return DateValidator(formatter: formatter, field: field)
        }
    }
}

class CharCountValidator: ValidatorConvertible {
    private let min: Int?
    private let max: Int?
    private let fieldName: String
    init(_ min: Int?,_ max: Int?, fieldName: String) {
        self.min = min
        self.max = max
        self.fieldName = fieldName
    }
    
    func errorMessage() -> Text {
        if let min = min, let max = max {
            if min == max {
                return Text().bold(fieldName).normal(" should be \(min) characters")
            } else {
                return Text().bold(fieldName).normal(" should be between \(min) and \(max) characters")
            }
        } else if let min = min {
            return Text().bold(fieldName).normal(" should be at least \(min) characters")
        } else if let max = max {
            return Text().bold(fieldName).normal(" can't be more than \(max) characters")
        } else {
            return Text().normal("Check ").bold(fieldName)
        }
    }
    
    func validated(_ value: String) throws -> Text {
        if value.isEmpty {return Text(string: value)}
        do {
            if try NSRegularExpression(pattern: "^.{\(min ?? 1),\(max ?? 50)}$",  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError(errorMessage())
            }
        } catch {
            throw ValidationError(errorMessage())
        }
        return Text(string: value)
    }
}

class NumberValidator: ValidatorConvertible {
    
    private let field: String
    
    init(_ field: String) {
        self.field = field
    }
    
    func validated(_ value: String) throws -> Text {
        if value.isEmpty {return Text(string: value)}
        do {
            if try NSRegularExpression(pattern: "^(\\d{10})|(([\\(]?([0-9]{3})[\\)]?)?[ \\.\\-]?([0-9]{3})[ \\.\\-]([0-9]{4}))$",  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError(Text().normal("Invalid ").bold(field))
            }
        } catch {
            throw ValidationError(Text().normal("Invalid ").bold(field))
        }
        return Text(string: value)
    }
}

struct RequiredFieldValidator: ValidatorConvertible {
    private let field: String
    
    init(_ field: String) {
        self.field = field
    }
    
    func validated(_ value: String) throws -> Text {
        guard !value.isEmpty else {
            throw ValidationError(Text().bold(field).normal(" is required"))
        }
        return Text(string: value)
    }
}

struct DateValidator: ValidatorConvertible {
    
    private let formatter: DateFormatter
    private let field: String
    
    init(formatter: DateFormatter, field: String = "Date") {
        self.formatter = formatter
        self.field = field
    }
    
    func validated(_ value: String) throws -> Text {
        if value.isEmpty {return Text(string: value)}
        if let _ = self.formatter.date(from: value) {
            return Text(string: value)
        } else {
            throw ValidationError(Text().bold(field).normal(" format should be \(formatter.dateFormat ?? "MM/DD/YYYY")"))
        }
    }
}

struct PasswordValidator: ValidatorConvertible {
    
    private let field: String
    
    init(_ field: String = "Password") {
        self.field = field
    }
    
    func validated(_ value: String) throws -> Text {
        if value.isEmpty {return Text(string: value)}
        return Text(string: value)
    }
}

struct EmailValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> Text {
        if value.isEmpty {return Text(string: value)}
        do {
            if try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError(Text().normal("Invalid ").bold("email address"))
            }
        } catch {
            throw ValidationError(Text().normal("Invalid ").bold("email address"))
        }
        return Text(string: value)
    }
}
