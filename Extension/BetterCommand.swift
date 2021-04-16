//
//  SourceEditorCommand.swift
//  Extension
//
//  Created by KC Chen on 2021/4/16.
//

import Foundation
import XcodeKit

class BetterCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        switch invocation.commandIdentifier {
        case "BetterHelloWorld":
            insertHelloWorl(source: invocation.buffer)
            completionHandler(nil)
            return
        case "BetterRemarkPrint":
            remark(leadingKey: "print", source: invocation.buffer)
            completionHandler(nil)
            return
        default:
            completionHandler(nil)
            return
        }
    }

    private func remark(leadingKey: String, source: XCSourceTextBuffer) {
        guard let selection = source.selections.firstObject as? XCSourceTextRange else {
            print("No selection")
            return
        }
        var start = 0, end = 0

        if selection.start.line == selection.end.line && selection.start.column == selection.end.column {
            start = 0
            end = source.lines.count - 1
        } else {
            start = selection.start.line
            end = selection.end.line
        }
        for index in start ... end {
            var line = source.lines[index] as! String
            if line.matches(String("^[\t| ]*print")) {
                var currentIndex = line.startIndex
                let startChar: Character = "p"

                while startChar != line[currentIndex] {
                    currentIndex = line.index(after: currentIndex)
                }

                line.insert(contentsOf: "//", at: currentIndex)
                source.lines[index] = line
            }
        }
    }

    private func insertHelloWorl(source: XCSourceTextBuffer) {
        guard let selection = source.selections.firstObject as? XCSourceTextRange else {
            print("No selection")
            return
        }

        print(selection.start.line, selection.start.column)
        print(selection.end.line, selection.end.column)

        source.lines.insert(indentation(line: source.lines[selection.start.line] as! String) + "print(\"Hello World\")", at: selection.start.line + 1)
    }

    private func indentation(line: String) -> String {
        if let nonWhitespace = line.rangeOfCharacter(from: CharacterSet.whitespaces.inverted) {
            return String(line.prefix(upTo: nonWhitespace.lowerBound))
        } else {
            return ""
        }
    }
}

extension String {
    func matches(_ regex: String) -> Bool {
        return range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
