//
//  StoriesView.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 23.02.2023.
//

import SwiftUI

struct StoriesView: View {
    
    @ObservedObject var presenter: StoriesPresenter
    
    @Environment(\.dismiss) var dismissCurrentView
    
    init(
        context: StoriesContext,
        eventHadler: StoriesEventHandler,
        collectionsManager: CollectionsManager
    ) {
        
        self.presenter = StoriesPresenter(
            context: context,
            eventHandler: eventHadler,
            collectionsManager: collectionsManager
        )
    }
    
    var body: some View {
        
        GeometryReader { proxy in
            
            ZStack {
                
                Color(hex: presenter.viewModel.viewBackgroundColor)
                    .animation(.linear, value: presenter.viewModel.presentedStoryId)
                    .ignoresSafeArea()
                    
                TabView(selection: $presenter.viewModel.presentedStoryId) {
                        
                    ForEach(presenter.viewModel.stories, id: \.id) { story in
                        
                        makeStory(story: story, proxy: proxy)
                            .tag(story.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .sheet(isPresented: $presenter.isPresentingCollections, content: {
            
            makeCollectionSheet()
                .presentationDetents([.fraction(0.1)])
                .onDisappear {
                    
                    presenter.collectionSheetDismissed()
                }
        })
        .onAppear {
            
            presenter.present()
        }
    }
}

private extension StoriesView {
    
    @ViewBuilder func makeCollectionSheet() -> some View {
            
        switch presenter.viewModel.collections {
        case let .populated(collections):
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack {
                    
                    ForEach(collections, id: \.id) { collection in
                        
                        collectionCover(collection: collection)
                    }
                }
                .padding([.leading, .trailing])
            }
            
        case .empty:
            Text("add collection")
                .padding()
        }
    }
    
    @ViewBuilder func collectionCover(collection: StoriesViewModel.CollectionState.Collection) -> some View {
        
        let isToBeSavedTo = presenter.collectionsToSaveTo.contains(where: { $0 == collection.id } )
        let isToBeRemoved = presenter.collectionToRemoveFrom.contains(where: { $0 == collection.id } )
        let alreadyInCollection = presenter.savedInCollection(collectionId: collection.id)
        
        ZStack(alignment: .topTrailing) {
            
            HStack {
                
                Text(collection.name)
                    .fontWeight(.bold)
                
                Text(collection.numberOfSaves)
                    .foregroundColor(.gray)
                    .opacity(0.5)
            }
            .padding(6)
            .background {
                
                RoundedRectangle(cornerRadius: 10)
                    .opacity(0.1)
            }
            .overlay {
                
                if alreadyInCollection {
                    
                    Color.blue
                        .opacity(0.3)
                }
                
                if isToBeRemoved {
                    
                    Color.red
                        .opacity(0.3)
                }
                
                if isToBeSavedTo {
                    
                    Color.yellow
                        .opacity(0.3)
                }
            }
        }
        .onTapGesture {
            
            if alreadyInCollection {
                
                presenter.collectionToRemoveFrom.append(collection.id)
            } else {
                
                presenter.collectionsToSaveTo.append(collection.id)
            }
        }
    }
}

//MARK: - make story

private extension StoriesView {
    
    @ViewBuilder func makeStory(story: Story, proxy: GeometryProxy) -> some View {
        
        let isStoryInCollection = presenter.isStoryInCollection(for: story.id)
            
        GeometryReader { proxy in
                
            AsyncImage(url: story.coverSource) { image in
                
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                
                Color(hex: story.coverBackground)
            }
            .overlay(
                
                HStack {
                    
                    Button {
                        
                        presenter.updateCollections()
                        presenter.isPresentingCollections = true
                    } label: {
                        
                        Image(systemName: isStoryInCollection ? "bookmark.fill" : "bookmark")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button {

                        dismissCurrentView()
                        presenter.handleClose()
                    } label: {

                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding()
                }

                , alignment: .top
            )
            .rotation3DEffect(
                
                provideAngle(proxy: proxy),
                axis: (x: 0, y: 1, z: 0),
                anchor: proxy.frame(in: .global).minX > 0 ? .leading : .trailing,
                perspective: 2.5
            )
            .clipShape(RoundedRectangle(cornerRadius: Constants.storyCornerRadius))
        }
    }
}

// MARK: - helper methods

private extension StoriesView {
    
    func provideAngle(proxy: GeometryProxy) -> Angle {
        
        let progress = proxy.frame(in: .global).minX / proxy.size.width
        
        let rotationAngle: CGFloat = 45
        let degrees = rotationAngle * progress
        
        return Angle(degrees: Double(degrees))
    }
}

// MARK: - Constants

private extension StoriesView {
    
    enum Constants {
        
        static let storyCornerRadius: CGFloat = 15
    }
}
