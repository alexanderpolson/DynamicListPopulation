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
    
    public func refresh() {
        self.nextPageReference = nil
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
        
        modelProvider.getModelPage(nextPageReference: nextPageReference, pageSize: pageSize) { newItemsPageResult in
            switch newItemsPageResult {
            case .success(let newItemsPage):
                // When loading the first page, make sure that items is empty. This
                // covers the refresh use case.
                if self.nextPageReference == nil {
                    // This emptying is done here to make sure we have the updated
                    // first page avaialble right away.
                    self.items = []
                }
                
                self.nextPageReference = newItemsPage.nextPageToken
                
                // Source: https://www.hackingwithswift.com/example-code/language/how-to-append-one-array-to-another-array
                if !newItemsPage.items.isEmpty {
                    self.items += newItemsPage.items

                    // Update population models so that the list updates properly
                    // TODO: This will need to cover the cases where we're at the beginning or end of the available items.
                    if self.nextPageReference != nil {
                        let tailUpdateIndex = self.items.count - (self.pageSize / 2)
                        self.tailUpdateModel = self.items[tailUpdateIndex]
                        print("Setting tail update index to \(tailUpdateIndex) (id: \(self.tailUpdateModel!.id)")
                    }

                }
            case .failure(let error):
                // TODO: Do something with the error.
                print(error)
            }
        }
    }
}
