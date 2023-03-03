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
    
    @Published var viewModel: StoriesViewModel
    
    private var isConfigured: Bool
    private var cancellables: Set<AnyCancellable>
    
    init(
        context: StoriesContext,
        eventHandler: StoriesEventHandler
    ) {
        
        self.context = context
        self.eventHandler = eventHandler
        self.viewModel = StoriesViewModel(
            presentedStoryId: context.intialStoryId,
            viewBackgroundColor: Constants.defaultBackgroundColor,
            stories: context.stories
        )
        
        self.isConfigured = false
        self.cancellables = Set<AnyCancellable>()
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
        
        let color = viewModel.stories.first(where: { $0.id == viewModel.presentedStoryId } )?.coverBackground ?? Constants.defaultBackgroundColor
        viewModel.viewBackgroundColor = color
    }
}

//MARK: - Constants

private extension StoriesPresenter {
    
    enum Constants {
        
        static let defaultBackgroundColor: String = "#ffffff"
    }
}
