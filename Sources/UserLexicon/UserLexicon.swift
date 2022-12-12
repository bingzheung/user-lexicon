import Foundation

private enum ULError: Error {
        case fileNotExists
        case canNotReadFile
        case fileIsEmpty
        case badLineFormat
        case badWord
        case hasSpacesInRomanizationTails
        case characterCountNotEqualToSyllableCount
        case badTone
        case badInitial
        case badFinal
}

@main
public struct UserLexicon {

        public static func main() {
                try! check(filePath: "latest.yaml")
                guard let paths = try? FileManager.default.contentsOfDirectory(atPath: "patches") else {
                        fatalError("can not access patches")
                }
                guard !paths.isEmpty else {
                        fatalError("patches is empty")
                }
                for path in paths {
                        let filePath: String = "patches/" + path
                        try! check(filePath: filePath)
                }
        }

        private static func check(filePath: String) throws {
                guard FileManager.default.fileExists(atPath: filePath) else {
                        print("File Path: \(filePath)")
                        throw ULError.fileNotExists
                }
                guard let latestContent: String = try? String(contentsOfFile: filePath) else {
                        print("File Path: \(filePath)")
                        throw ULError.canNotReadFile
                }

                let sourceLines: [String] = latestContent
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .trimmingCharacters(in: .controlCharacters)
                        .components(separatedBy: .newlines)
                        .map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                        .filter({ !($0.isEmpty || $0.hasPrefix("#")) })
                guard !sourceLines.isEmpty else {
                        print("File Path: \(filePath)")
                        throw ULError.fileIsEmpty
                }

                for line in sourceLines {
                        let parts = line.split(separator: "\t")
                        guard parts.count > 1 && parts.count < 4 else {
                                print("LineText: \(line)")
                                throw ULError.badLineFormat
                        }
                        let word = parts[0]
                        let romanization = parts[1]
                        let droppedCommasWord = word.replacingOccurrences(of: "，", with: "")

                        let isFineWord: Bool = droppedCommasWord.filter({ $0.isPunctuation || $0.isWhitespace || $0.isASCII }).isEmpty
                        guard isFineWord else {
                                print("LineText: \(line)")
                                throw ULError.badWord
                        }
                        let hasSpacesInRomanizationTails: Bool = romanization.hasPrefix(" ") || romanization.hasSuffix(" ")
                        guard !hasSpacesInRomanizationTails else {
                                print("LineText: \(line)")
                                throw ULError.hasSpacesInRomanizationTails
                        }

                        let syllables = romanization.split(separator: " ")
                        guard droppedCommasWord.count == syllables.count else {
                                print("LineText: \(line)")
                                throw ULError.characterCountNotEqualToSyllableCount
                        }

                        for syllable in syllables {
                                let tone = syllable.last!
                                guard tones.contains(tone) else {
                                        print("LineText: \(line)")
                                        throw ULError.badTone
                                }
                                let withoutTone = syllable.dropLast()
                                let m_or_ng: Bool = withoutTone == "m" || withoutTone == "ng"
                                guard !m_or_ng else { return }
                                let isPluralInitial: Bool = syllable.hasPrefix("ng") || syllable.hasPrefix("gw") || syllable.hasPrefix("kw")
                                if isPluralInitial {
                                        let final = withoutTone.dropFirst(2)
                                        guard finals.contains(String(final)) else {
                                                print("LineText: \(line)")
                                                throw ULError.badFinal
                                        }
                                } else {
                                        let lingShingMou: Bool = finals.contains(String(withoutTone))
                                        guard !lingShingMou else { return }
                                        let final = withoutTone.dropFirst()
                                        guard finals.contains(String(final)) else {
                                                print("LineText: \(line)")
                                                throw ULError.badFinal
                                        }
                                }
                        }
                }
        }

        private static let initials: Set<String> = [
                "b",
                "p",
                "m",
                "f",
                "d",
                "t",
                "n",
                "l",
                "g",
                "k",
                "ng",
                "h",
                "gw",
                "kw",
                "w",
                "z",
                "c",
                "s",
                "j",
        ]
        private static let singularInitials: Set<Character> = [
                "b",
                "p",
                "m",
                "f",
                "d",
                "t",
                "n",
                "l",
                "g",
                "k",
                "h",
                "w",
                "z",
                "c",
                "s",
                "j",
        ]
        private static let finals: Set<String> = [
                "aa",
                "aai",
                "aau",
                "aam",
                "aan",
                "aang",
                "aap",
                "aat",
                "aak",

                "a",
                "ai",
                "au",
                "am",
                "an",
                "ang",
                "ap",
                "at",
                "ak",

                "e",
                "ei",
                "eu",
                "em",
                "en",
                "eng",
                "ep",
                "et",
                "ek",

                "i",
                "iu",
                "im",
                "in",
                "ing",
                "ip",
                "it",
                "ik",

                "o",
                "oi",
                "ou",
                "on",
                "ong",
                "ot",
                "ok",

                "u",
                "ui",
                "um",
                "un",
                "ung",
                "up",
                "ut",
                "uk",

                "oe",
                "oeng",
                "oet",
                "oek",

                "eoi",
                "eon",
                "eot",

                "yu",
                "yun",
                "yut",
        ]

        private static let tones: Set<Character> = ["1", "2", "3", "4", "5", "6"]
}

