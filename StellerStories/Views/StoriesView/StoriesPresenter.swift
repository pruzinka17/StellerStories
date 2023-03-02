//
//  StoriesPresenter.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 28.02.2023.
//

import Foundation

final class StoriesPresenter: ObservableObject {
    
    @Published var viewModel: StoriesViewModel
    
    init(context: StoriesContext) {
        
        self.viewModel = StoriesViewModel(presentedStoryId: context.intialStoryId, viewBackgroundColor: "", stories: context.stories)
    }
}

//MARK: - Helper methods

extension StoriesPresenter {
    
    func provideColor() -> String {
        
        return viewModel.stories.first(where: { $0.id == viewModel.presentedStoryId } )?.coverBackground ?? Constants.defaultBackgroundColor
    }
}

//MARK: - Constants

private extension StoriesPresenter {
    
    enum Constants {
        
        static let defaultBackgroundColor: String = "#ffffff"
    }
}
