//
//  ModelPage.swift
//  SwiftUIDynamicListPopulation
//
//  Created by Alexander Polson on 9/22/21.
//

import Foundation

public struct ModelPage<M, T> {
    var items: [M]
    var nextPageToken: T?
    
    public init(items: [M], nextPageToken: T?) {
        self.items = items
        self.nextPageToken = nextPageToken
    }
}
