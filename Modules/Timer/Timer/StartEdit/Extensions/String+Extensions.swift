import Foundation
import Utils

extension String {
    
    public func findTokenAndQueryMatchesForAutocomplete(
        _ token: Character,
        _ cursorPosition: Int
    ) -> (Character?, String) {
        return findTokenAndQueryMatchesForAutocomplete([token], cursorPosition)
    }
    
    public func findTokenAndQueryMatchesForAutocomplete(
        _ tokens: [Character],
        _ cursorPosition: Int
    ) -> (Character?, String) {
        
        do {
            let joinedTokens = tokens.map { String($0) }.joined(separator: "|")
            let regex = try NSRegularExpression(pattern: "(^| )(\(joinedTokens))")
            let searchRange = startIndex..<index(startIndex, offsetBy: cursorPosition.clamp(min: 0, max: self.count))
            let matches = regex.matches(in: self, range: NSRange(searchRange, in: self))
            
            guard let match = matches.last else { return (nil, self) }
            
            let queryStart = index(startIndex, offsetBy: match.range.lowerBound)
            let matchSubstring = self[queryStart..<endIndex]
            let matchedTheFirstWord = tokens.contains { matchSubstring.starts(with: String($0)) }
            let queryWithToken = String(matchedTheFirstWord ? matchSubstring : matchSubstring.dropFirst())
            
            let token = queryWithToken.first
            let query = String(queryWithToken.dropFirst())
            
            return (token, query)

        } catch {
            return (nil, "")
        }
    }
    
    static func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
}
