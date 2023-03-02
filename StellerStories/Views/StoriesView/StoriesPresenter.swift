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
    
    @Published var viewModel: StoriesViewModel
    
    private var isConfigured: Bool
    private var cancellables: [AnyCancellable]
    
    init(context: StoriesContext) {
        
        self.context = context
        self.viewModel = StoriesViewModel(
            presentedStoryId: context.intialStoryId,
            viewBackgroundColor: Constants.defaultBackgroundColor,
            stories: context.stories
        )
        
        self.isConfigured = false
        self.cancellables = []
    }
}

// MARK: - Public methods

extension StoriesPresenter {
    
    func present() {
        
        guard !isConfigured else {
            return
        }
        
        updateView()
        
        $viewModel.map(\.presentedStoryId)
            .removeDuplicates()
            .sink { [weak self] newStoryId in
                
                self?.updateView()
            }.store(in: &cancellables)
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
