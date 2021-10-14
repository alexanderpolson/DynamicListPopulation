//
//  ModelProvider.swift
//  SwiftUIDynamicListPopulation
//
//  Created by Alexander Polson on 9/22/21.
//

import Foundation

public protocol ModelProvider {
    associatedtype ModelType: Identifiable
    associatedtype NextPageReference
    
    func getModelPage(nextPageReference: NextPageReference?, pageSize: Int, completionHandler: @escaping (Result<ModelPage<ModelType, NextPageReference>, Error>) -> Void)
}
