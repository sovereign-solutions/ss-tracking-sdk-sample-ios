//
//  SVString+ext.swift
//  SVTracking
//
//  Created by LAP01857 on 1/5/22.
//

import Foundation

public extension String {

  static func ==(lhs: String, rhs: String) -> Bool {
    return lhs.compare(rhs, options: .numeric) == .orderedSame
  }

  static func <(lhs: String, rhs: String) -> Bool {
    return lhs.compare(rhs, options: .numeric) == .orderedAscending
  }

  static func <=(lhs: String, rhs: String) -> Bool {
    return lhs.compare(rhs, options: .numeric) == .orderedAscending || lhs.compare(rhs, options: .numeric) == .orderedSame
  }

  static func >(lhs: String, rhs: String) -> Bool {
    return lhs.compare(rhs, options: .numeric) == .orderedDescending
  }

  static func >=(lhs: String, rhs: String) -> Bool {
    return lhs.compare(rhs, options: .numeric) == .orderedDescending || lhs.compare(rhs, options: .numeric) == .orderedSame
  }

}
