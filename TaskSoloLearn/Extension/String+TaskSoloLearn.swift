//
//  String+TaskSoloLearn.swift
//  TaskSoloLearn
//
//  Created by Armen Alikhanyan on 4/21/19.
//  Copyright © 2019 ArmenAlikhanyan. All rights reserved.
//
import Foundation
import UIKit

extension String {
    
    func removeExtraSpacesAndNotAlphanumericCharacters() -> String {
        var pattern = "[^A-Za-z0-9 ]+"
        // replace all not alphanumeric characters to space
        var alphanumericString = self.replacingOccurrences(of: pattern, with: " ", options: [.regularExpression])
        
        pattern = "[\\s\n]+"
        // removing all extra spaces
        alphanumericString = alphanumericString.replacingOccurrences(of: pattern, with: " ", options: .regularExpression, range: nil)
        return alphanumericString
    }
    
    func multipleStringsAndCountsFromText() -> [(String, Int)] {
        
        let correctedString = self.removeExtraSpacesAndNotAlphanumericCharacters()
        var stringsArray = correctedString.lowercased().components(separatedBy: " ")

        // remove words if character count is 1
        stringsArray = stringsArray.filter { $0.count > 1 }

        // All strings from array and repeats counts [String : Count]
        let counts = stringsArray.reduce(into: [:]) { counts, word in counts[word, default: 0] += 1 }
        
        var multipleStringsArray = [(key: String, value: Int)]()
        // All reapets strings if repeatCount > 9
        for item in counts {
            if item.value > 9 {
                multipleStringsArray.append(item)
            }
        }
        // Sorte by alphabetically
        multipleStringsArray = multipleStringsArray.sorted{ $0.key.localizedCaseInsensitiveCompare($1.key) == ComparisonResult.orderedAscending }

        return multipleStringsArray
    }
    
    func ranges(_ word: String) -> [NSRange] {
        var ranges: [Range<Index>] = []
        while ranges.last.map({ $0.upperBound < self.endIndex }) ?? true,
            let range = self.range(of: word, options: .literal, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex)
        {
            ranges.append(range)
        }
        
        var nsRanges = [NSRange]()
        for item in ranges {
            let nsRange = self.nsRange(from: item)
            // for example : "initialization" contains "on", but "initialization" != "on"
            if self.isFullWordInRange(range: nsRange) {
                nsRanges.append(nsRange)
            }
        }
        return nsRanges
    }
    
    func width(withConstantdHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let atributes = [NSAttributedString.Key.font: font]
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: atributes, context: nil)
        
        return ceil(boundingBox.width)
    }
    
    // MARK: - PRIVATE
    private func isFullWordInRange(range: NSRange) -> Bool {
        
        let afterCharacterRange = NSRange.init(location: range.location + range.length, length: 1)
        let beforCharacterRange = NSRange.init(location: range.location - 1, length: 1)
        
        if self.isAlphanumericCharacter(afterCharacterRange) || self.isAlphanumericCharacter(beforCharacterRange) {
            return false
        }
        return true
    }
    
    private func isAlphanumericCharacter(_ inRange : NSRange) -> Bool {
        if inRange.location < 0 || (inRange.location + inRange.length) > self.count {
            return false
        }
        let text = self as NSString
        let character = text.substring(with: inRange)
        return !character.isEmpty && character.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
        
    }

}

extension StringProtocol where Index == String.Index {
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}
