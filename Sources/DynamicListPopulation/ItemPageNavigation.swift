//
//  ItemPageNavigation.swift
//  SwiftUIDynamicListPopulation
//
//  Created by Alexander Polson on 9/20/21.
//

import Foundation

// Source: https://www.hackingwithswift.com/quick-start/swiftui/whats-the-difference-between-observedobject-state-and-environmentobject
// Source: https://stackoverflow.com/questions/59868393/swiftui-pagination-for-list-object
public class ItemPageNavigation<MP: ModelProvider>: ObservableObject {
    // Associated types-fu:
    // Source: https://www.hackingwithswift.com/example-code/language/how-to-fix-the-error-protocol-can-only-be-used-as-a-generic-constraint-because-it-has-self-or-associated-type-requirements
    private var modelProvider: MP
    @Published public private(set) var items: [MP.ModelType]
    private var nextPageReference: MP.NextPageReference?
    private var pageSize: Int
    private var initialCapacity: Int
    private var tailUpdateModel: MP.ModelType?
    
    public init(initialCapacity: Int = 20, pageSize: Int = 20, modelProvider: MP) {
        self.modelProvider = modelProvider
        self.items = []
        self.pageSize = pageSize
        self.initialCapacity = initialCapacity
        
        populateNextPage()
    }
    
    public func updateItems(model: MP.ModelType) {
        // TODO: Figure out how to clean up older entries?
        // When deleting items, the list jumps up, causing even more items to
        // be added.
        
        if let tailUpdateModel = tailUpdateModel {
            if tailUpdateModel.id == model.id {
                guard nextPageReference != nil else {
                    return
                }
                
                self.tailUpdateModel = nil
                print("Tail update model appeared (id: \(model.id). Populating next page.")
                populateNextPage()
            }
        }
    }
    
    private func populateNextPage() {
        // Make sure that additional events aren't triggered while items are updated.
        tailUpdateModel = nil
        
        print("Populating next page")
        
        let newItemsPage = modelProvider.getModelPage(nextPageReference: nextPageReference, pageSize: pageSize)
        nextPageReference = newItemsPage.nextPageToken
        // Source: https://www.hackingwithswift.com/example-code/language/how-to-append-one-array-to-another-array
        items += newItemsPage.items
        
        // Update population models so that the list updates properly
        // TODO: This will need to cover the cases where we're at the beginning or end of the available items.
        let tailUpdateIndex = items.count - 15
        tailUpdateModel = items[tailUpdateIndex]
        print("Setting tail update index to \(tailUpdateIndex) (id: \(tailUpdateModel!.id)")
    }
}
