//
//  NetworkError.swift
//  TalkLeague
//
//  Created by Manu Singh on 05/06/20.
//  Copyright © 2020 neargroup. All rights reserved.
//

import Foundation

public struct NetworkError : LocalizedError,CustomStringConvertible {
    
    public var description : String
    
    public init(_ description : String) {
        self.description = description
    }
    
    public var errorDescription: String? {
        get {
            return self.description
        }
    }
}
