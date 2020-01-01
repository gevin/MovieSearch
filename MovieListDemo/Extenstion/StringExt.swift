//
//  StringExtension.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/27.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

extension String {
    
    func MD5() -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = self.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        // swift 3
        //let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        // swfit 4
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        // swift 3
        //let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        // swift 4
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }

    func encodeUrl() -> String? {
//        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlHostAllowed)
        // "#%/:<>?@[\]^`{|};&=+$,. "
        var allowedQueryParamAndKey = NSCharacterSet.urlQueryAllowed
        allowedQueryParamAndKey.remove(charactersIn: "#%/:<>?@[]\\^`{|};&=+$,. ")
        return self.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey)
    }

    func decodeUrl() -> String? {
        return self.removingPercentEncoding
    }
    
    public func substring(from index: Int) -> String {
        if self.count > index {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let subString = self[startIndex..<self.endIndex]
            
            return String(subString)
        } else {
            return self
        }
    }
    
    public func substring(from index: Int, to endIndex: Int) -> String {
        if self.count > index && self.count > endIndex {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let endIndex = self.index(self.startIndex, offsetBy: endIndex)
            let subString = self[startIndex..<endIndex]
            
            return String(subString)
        } else {
            return self
        }
    }
    
    /// 把網頁特殊字元的代碼轉回來，ex: &quot; -> \", &amp; -> &
    public func htmlEntityDecode() -> String {
        var string = self
        string = string.replacingOccurrences(of: "&quot;", with: "\"")
        string = string.replacingOccurrences(of: "&apos;", with: "'")
        string = string.replacingOccurrences(of: "&lt;", with: "<")
        string = string.replacingOccurrences(of: "&gt;", with: ">")
        string = string.replacingOccurrences(of: "&amp;", with: "&") // Do this last so that, e.g. @"&amp;lt;" goes to @"&lt;" not @"<"
    
        return string
    }
    
}

extension StringProtocol where Index == String.Index {
    func index(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range.lowerBound)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    
    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    
//    func indexDistance(of string: Self) -> Int? {
//        guard let index = range(of: string) else { return nil }
//        return distance(from: startIndex, to: index)
//    }
}
