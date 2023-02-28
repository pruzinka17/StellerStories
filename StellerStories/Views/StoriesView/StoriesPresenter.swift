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
        
        self.viewModel = StoriesViewModel(presentedStoryId: context.intialStoryId, stories: context.stories)
    }
}
