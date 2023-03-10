//
//  StoriesPresenter.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 28.02.2023.
//

import Foundation
import Combine

final class StoriesPresenter: ObservableObject {
    
    private let context: StoriesContext
    private let eventHandler: StoriesEventHandler
    private let collectionsManager: CollectionsManager
    
    private var isConfigured: Bool
    private var cancellables: Set<AnyCancellable>
    
    @Published var viewModel: StoriesViewModel
    
    @Published var isPresentingCollections: Bool
    
    @Published var collectionsToSaveTo: [String]
    @Published var collectionToRemoveFrom: [String]
    
    init(
        context: StoriesContext,
        eventHandler: StoriesEventHandler,
        collectionsManager: CollectionsManager
    ) {
        
        self.context = context
        self.eventHandler = eventHandler
        self.collectionsManager = collectionsManager
        
        self.isConfigured = false
        self.cancellables = Set<AnyCancellable>()
        
        self.viewModel = StoriesViewModel(
            presentedStoryId: context.intialStoryId,
            viewBackgroundColor: Constants.defaultBackgroundColor,
            stories: context.stories,
            collections: .empty
        )
        
        self.isPresentingCollections = false
        
        self.collectionsToSaveTo = []
        self.collectionToRemoveFrom = []
    }
}

// MARK: - Collection methods

extension StoriesPresenter {
    
    func collectionSheetDismissed() {
        
        saveStoryToCollections()
        collectionsToSaveTo = []
        
        removeStoryFromCollections()
        collectionToRemoveFrom = []
    }
    
    func collectionClicked(collectionId: String) {
        
        collectionsToSaveTo.append(collectionId)
    }
    
    func savedInCollection(collectionId: String) -> Bool {
        
        let collections = collectionsManager.storyInCollections(userId: context.userId, storyId: viewModel.presentedStoryId)
        
        return collections.contains(where: { $0 == collectionId } )
    }
    
    func isStoryInCollection(for storyId: String) -> Bool {
        
        return collectionsManager.isStorySaved(userId: context.userId, storyId: storyId)
    }
    
    func updateCollections() {
        
        let collections = collectionsManager.provideCollections(for: context.userId)
        
        var items: [StoriesViewModel.CollectionState.Collection] = []
        
        for collection in collections {
            
            let item = StoriesViewModel.CollectionState.Collection(
                id: collection.id,
                name: collection.name,
                numberOfSaves: String(collection.storyIds.count)
            )
            
            items.append(item)
        }
        
        if items.isEmpty {
            
            viewModel.collections = .empty
        } else {
            
            viewModel.collections = .populated(items.reversed())
        }
    }
}

private extension StoriesPresenter {
    
    func saveStoryToCollections() {
        
        collectionsManager.addStoryToCollections(collectionIds: collectionsToSaveTo, userId: context.userId, storyId: viewModel.presentedStoryId)
    }
    
    func removeStoryFromCollections() {
        
        collectionsManager.removeStoryFromCollections(from: collectionToRemoveFrom, userId: context.userId, storyId: viewModel.presentedStoryId)
    }
    
}

// MARK: - Public methods

extension StoriesPresenter {
    
    func present() {
        
        guard !isConfigured else {
            return
        }
        
        isConfigured = true
        
        updateView()
        
        let publisher = $viewModel
            .map(\.presentedStoryId)
            .receive(on: DispatchQueue.main)
            
        
        publisher.sink { [weak self] newStoryId in
            
            self?.updateView()
        }.store(in: &cancellables)
    }
    
    func handleClose() {
        
        let currentId = viewModel.presentedStoryId
        eventHandler.onStoryIdChange(currentId)
    }
}

// MARK: - Update methods

private extension StoriesPresenter {
    
    func updateView() {
        
        let color = viewModel.stories.first(
            where: { $0.id == viewModel.presentedStoryId }
        )?.coverBackground ?? Constants.defaultBackgroundColor
        
        viewModel.viewBackgroundColor = color
    }
}

// MARK: - Constants

private extension StoriesPresenter {
    
    enum Constants {
        
        static let defaultBackgroundColor: String = "#ffffff"
    }
}
