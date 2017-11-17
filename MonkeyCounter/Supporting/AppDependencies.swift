//
//  AppDependencies.swift
//  MonkeyCounter
//
//  Created by AT on 9/29/16.
//  Copyright © 2016 AT. All rights reserved.
//

import Foundation
import Swinject

class AppDependencies {
    
    let container = Container() { container in
        
        // user
        container.register(UserSettingsModeling.self) { r in
            
            return UserSettingsModel()
            }.inObjectScope(.container)
        
        // core data
        container.register(ATCoreDataManager.self) { r in
            let modelUrl = ATCoreDataManager.defaultModelUrl!
            let storeUrl = ATCoreDataManager.defaultStoreUrl
            return ATCoreDataManager(modelUrl: modelUrl,
                                     storeUrl: storeUrl,
                                     concurrencyType: .privateQueueConcurrencyType)
        }.inObjectScope(.container)
        
        // location
        container.register(MCRegionMonitoring.self) { r in
            
            return MCRegionMonitor()
        }.inObjectScope(.container)
        
        // view model
        container.register(EventViewModeling.self) { r in
            
            let eventStore = r.resolve(EventStoreModeling.self)!

            return EventViewModel(eventStore: eventStore)
            }
        
        container.register(MonkeyChatViewModeling.self) { r in
            
            let dataManager = r.resolve(ATCoreDataManager.self)!
            let eventStore = r.resolve(EventStoreModeling.self)!
            let chatData = r.resolve(ChatDataFlowing.self)!
            let userSettings = r.resolve(UserSettingsModeling.self)!
            
            return MonkeyChatModel(dataManager: dataManager,
                                   eventStore: eventStore,
                                   chatData: chatData,
                                   userSettings: userSettings)
            }

        // layout
        container.register(CounterCVLayout.self) { _ in
            return CounterCVLayout()
            }.inObjectScope(.container)
        
        // data
        container.register(ChatDataFlowing.self) { r in
            
            let userSettings = r.resolve(UserSettingsModeling.self)!
            return ChatDataFlow(userSettings: userSettings)
            }
        
        // models
        container.register(CheckinStoreModeling.self) { r in
            
            let dataManager = r.resolve(ATCoreDataManager.self)!
            
            return CheckinStoreModel(dataManager: dataManager)
            }.inObjectScope(.container)
        
        container.register(EventStoreModeling.self) { r in
            
            let dataManager = r.resolve(ATCoreDataManager.self)!
            let checkinStore = r.resolve(CheckinStoreModeling.self)!
            let regionMonitor = r.resolve(MCRegionMonitoring.self)!
            
            return EventStoreModel(dataManager: dataManager, checkinStore: checkinStore, regionMonitor: regionMonitor)
            }.inObjectScope(.container)
        
        
        // view controllers
        container.register(MonkeyChatVC.self) { r in
            
            let chatVC = MonkeyChatVC(nibName: nil, bundle: nil)
            chatVC.viewModel = r.resolve(MonkeyChatViewModeling.self)!
            
            return chatVC
        }
        
        // storyboard
        container.storyboardInitCompleted(EventFeedVC.self) { r, c in
            c.layout = r.resolve(CounterCVLayout.self)!
            c.viewModel = r.resolve(EventViewModeling.self)!
            c.storeModel = r.resolve(EventStoreModeling.self)!
            c.checkinModel = r.resolve(CheckinStoreModeling.self)!
        }
        
        container.storyboardInitCompleted(ChatNavigationController.self) { _ in
        }
    }
}
