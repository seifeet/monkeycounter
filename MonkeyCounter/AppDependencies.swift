//
//  AppDependencies.swift
//  Nebula
//
//  Created by AT on 6/6/16.
//  Copyright © 2016 Visva. All rights reserved.
//

import Foundation
import UIKit
import Swinject

class AppDependencies {
    
    let container = Container() { container in
        // action data
        container.register(ActiveData.self) { _ in ActiveData() }.inObjectScope(.container)
        
        // root
        container.register(RootWireframe.self) { _ in RootWireframe() }.inObjectScope(.container)
        
        // core data
        container.register(VVCoreDataManager.self) { r in
            let modelUrl = VVCoreDataManager.defaultModelUrl!
            let storeUrl = VVCoreDataManager.defaultStoreUrl
            return VVCoreDataManager(modelUrl: modelUrl, storeUrl: storeUrl)
        }
        
        // parse
        container.register(ParseObjectParser.self) { r in
            let activeData = r.resolve(ActiveData.self)!
            return ParseObjectParser(activeData: activeData)
        }
        
        container.register(ParseCommService.self) { r in
            let activeData = r.resolve(ActiveData.self)!
            let parseObjectParser = r.resolve(ParseObjectParser.self)!
            return ParseCommService(parseObjectParser: parseObjectParser, activeData: activeData)
        }
        
        container.register(ParseLoginHelper.self) { r in
            let parseCommService = r.resolve(ParseCommService.self)!
            return ParseLoginHelper(parseCommService: parseCommService)
        }
        
        // settings
        container.register(SettingsViewController.self) { r in
            let settingsPresenter = r.resolve(SettingsPresenter.self)!
            let activeData = r.resolve(ActiveData.self)!
            let settingsHelper = r.resolve(SettingsHelper.self)!
            
            return SettingsViewController(eventHandler: settingsPresenter, activeData: activeData, helper: settingsHelper)
        }
        container.register(SettingsWireframe.self) { _ in
            let settingsViewController = container.resolve(SettingsViewController.self)!
            
            return SettingsWireframe(viewController: settingsViewController)
        }
        container.register(SettingsPresenter.self) { r in
            let activeData = r.resolve(ActiveData.self)!
            return SettingsPresenter(activeData: activeData)
            }.initCompleted { r, c in
                c.settingsWireframe = r.resolve(SettingsWireframe.self)!
        }
        container.register(SettingsHelper.self) { r in
            let activeData = r.resolve(ActiveData.self)!
            return SettingsHelper(activeData: activeData)
        }
        container.register(ChangePasswordViewController.self) { r in
            let settingsPresenter = r.resolve(SettingsPresenter.self)!
            let parseCommService = r.resolve(ParseCommService.self)!
            
            return ChangePasswordViewController(eventHandler: settingsPresenter, parseCommService: parseCommService)
        }
        container.register(ChangeEmailViewController.self) { r in
            let settingsPresenter = r.resolve(SettingsPresenter.self)!
            let parseCommService = r.resolve(ParseCommService.self)!
            let activeData = r.resolve(ActiveData.self)!
            
            return ChangeEmailViewController(eventHandler: settingsPresenter, activeData: activeData, parseCommService: parseCommService)
        }
        
        // post
        container.register(PostCommService.self) { _ in PostCommService() }
        
        // post add
        container.register(PostAddViewController.self) { r in
            let postAddPresenter = r.resolve(PostAddPresenter.self)!
            
            return PostAddViewController(eventHandler: postAddPresenter)
        }
        container.register(PostAddInteractor.self) { r in
            let activeData = r.resolve(ActiveData.self)!
            let postAddPresenter = r.resolve(PostAddPresenter.self)!
            let postCommService = r.resolve(PostCommService.self)!
            return PostAddInteractor(postAddInteractorOutput: postAddPresenter, postCommService:postCommService, activeData: activeData)
        }
        container.register(PostAddWireframe.self) { r in
            let postAddViewController = r.resolve(PostAddViewController.self)!
            
            return PostAddWireframe(viewController: postAddViewController)
        }
        container.register(PostAddPresenter.self) { r in
            let activeData = r.resolve(ActiveData.self)!
            return PostAddPresenter(activeData: activeData)
            }.initCompleted { r, c in
                c.postAddWireframe = r.resolve(PostAddWireframe.self)!
                c.postAddInteractor = r.resolve(PostAddInteractor.self)!
                c.postAddViewInterface = r.resolve(PostAddViewController.self)!
        }
        
        // post detail
        container.register(PostDetailViewController.self) { r in
            let postDetailPresenter = r.resolve(PostDetailPresenter.self)!
            
            return PostDetailViewController(eventHandler: postDetailPresenter)
        }
        container.register(PostDetailInteractor.self) { r in
            let activeData = r.resolve(ActiveData.self)!
            let postDetailPresenter = r.resolve(PostDetailPresenter.self)!
            let postCommService = r.resolve(PostCommService.self)!
            return PostDetailInteractor(postDetailInteractorOutput: postDetailPresenter, postCommService:postCommService, activeData: activeData)
        }
        container.register(PostDetailWireframe.self) { r in
            let postDetailPresenter = r.resolve(PostDetailPresenter.self)!
            let rootWireframe = r.resolve(RootWireframe.self)!
            let postDetailViewController = r.resolve(PostDetailViewController.self)!
            return PostDetailWireframe(postDetailPresenter: postDetailPresenter, rootWireframe: rootWireframe, viewController: postDetailViewController)
        }
        container.register(PostDetailPresenter.self) { r in
            let postDetailPresenter = PostDetailPresenter()
            return postDetailPresenter
            }.initCompleted { r, c in
                c.postDetailWireframe = r.resolve(PostDetailWireframe.self)!
                c.postDetailInteractor = r.resolve(PostDetailInteractor.self)!
        }
        
        // post list
        container.register(PostListInteractor.self) { r in
            let activeData = r.resolve(ActiveData.self)!
            let postListPresenter = r.resolve(PostListPresenter.self)!
            let postCommService = r.resolve(PostCommService.self)!
            return PostListInteractor(postListInteractorOutput: postListPresenter, activeData: activeData, postCommService:postCommService)
        }
        container.register(PostListViewController.self) { r in
            let postListPresenter = r.resolve(PostListPresenter.self)!
            
            return PostListViewController(eventHandler: postListPresenter)
        }
        container.register(PostListPresenter.self) { r in
            let postPresenter = PostListPresenter()
            return postPresenter
            }.initCompleted { r, c in
                c.postWireframe = r.resolve(PostListWireframe.self)!
                c.postInteractor = r.resolve(PostListInteractor.self)!
        }
        container.register(PostListWireframe.self) { r in
            let postAddWireframe = r.resolve(PostAddWireframe.self)!
            let postDetailWireframe = r.resolve(PostDetailWireframe.self)!
            let postListViewController = r.resolve(PostListViewController.self)!
            
            return PostListWireframe(postAddWireframe:postAddWireframe, postDetailWireframe:postDetailWireframe, viewController: postListViewController)
        }
        
        // Login views
        container.register(LoginSignUpInteractor.self) { r in
            let parseCommService = r.resolve(ParseCommService.self)!
            let loginInteractor = LoginSignUpInteractor(parseCommService:parseCommService)
            
            loginInteractor.outputLogin = r.resolve(LoginPresenter.self)!
            loginInteractor.outputSignup = r.resolve(SignUpPresenter.self)!
            loginInteractor.outputUsername = r.resolve(UsernameSelectPresenter.self)!
            
            return loginInteractor
        }
        container.register(LoginWireframe.self) { r in
            let rootWireframe = r.resolve(RootWireframe.self)!
            let activeData = r.resolve(ActiveData.self)!
            let parseLoginHelper = r.resolve(ParseLoginHelper.self)!
            let loginWireframe = LoginWireframe(rootWireframe: rootWireframe, activeData: activeData, parseLoginHelper: parseLoginHelper)
            
            loginWireframe.loginPresenter = r.resolve(LoginPresenter.self)!
            loginWireframe.signupPresenter = r.resolve(SignUpPresenter.self)!
            loginWireframe.usernamePresenter = r.resolve(UsernameSelectPresenter.self)!
            
            return loginWireframe
        }
        container.register(LoginPresenter.self) { r in
            let loginPresenter = LoginPresenter()
            return loginPresenter
            }.initCompleted { r, c in
                c.loginInteractor = r.resolve(LoginSignUpInteractor.self)!
                c.loginWireframe = r.resolve(LoginWireframe.self)!
        }
        container.register(SignUpPresenter.self) { r in
            let signupPresenter = SignUpPresenter()
            return signupPresenter
            }.initCompleted { r, c in
                c.signUpInteractor = r.resolve(LoginSignUpInteractor.self)!
                c.loginWireframe = r.resolve(LoginWireframe.self)!
        }
        container.register(UsernameSelectPresenter.self) { r in
            let usernamePresenter = UsernameSelectPresenter()
            return usernamePresenter
            }.initCompleted { r, c in
                c.usernameInteractor = r.resolve(LoginSignUpInteractor.self)!
                c.loginWireframe = r.resolve(LoginWireframe.self)!
        }
        
        // terms of service
        container.register(LegalCommService.self) { _ in LegalCommService() }
        container.register(TermsOfServiceView.self) { r in
            let legalCommService = r.resolve(LegalCommService.self)!
            return TermsOfServiceView(legalCommService: legalCommService)
        }
        
        // Reaction Manager
        container.register(ReactionManagerPresenter.self) { r in
            let managerWirefreame = r.resolve(ReactionManagerWireFrame.self)!
            let managerInteractor = r.resolve(ReactionManagerInteractor.self)!
            let reactionManagerPresenter = ReactionManagerPresenter(managerInteractor: managerInteractor, managerWireframe: managerWirefreame)
            return reactionManagerPresenter
        }
        container.register(ReactionManagerInteractor.self) { r in
            let managerInteractor = ReactionManagerInteractor()
            return managerInteractor
            }.initCompleted { r, c in
                c.reactionPresenter = r.resolve(ReactionManagerPresenter.self)!
        }
        
        container.register(ReactionManagerWireFrame.self) { r in
            return ReactionManagerWireFrame()
            }.initCompleted { r, c in
                c.reactionPresenter = r.resolve(ReactionManagerPresenter.self)!
        }
        
        //Activity Screen
        container.register(ActivityWireframe.self) { r in
            let activityViewController = ActivityViewController()
            
            return ActivityWireframe(viewController: activityViewController)
        }
        
        //Saved Content Screen
        container.register(SavedContentWireframe.self) { r in
            let savedContentViewController = SavedContentViewController()
            
            return SavedContentWireframe(viewController: savedContentViewController)
        }
        
        // tab bar
        container.register(TabBarWireframe.self) { r in
            let postListWireframe = r.resolve(PostListWireframe.self)!
            let activityWireframe = r.resolve(ActivityWireframe.self)!
            let postAddWireframe  = r.resolve(PostAddWireframe.self)!
            let savedWireframe    = r.resolve(SavedContentWireframe.self)!
            let settingsWireframe = container.resolve(SettingsWireframe.self)!
            let rootWireframe = container.resolve(RootWireframe.self)!
            
            return TabBarWireframe(rootWireframe: rootWireframe, postListWireframe, activityWireframe, postAddWireframe, savedWireframe, settingsWireframe)
        }

    }

    func installTabBarControllerIntoWindow(_ window: UIWindow) {
        let tabBarWireframe = container.resolve(TabBarWireframe.self)!

        tabBarWireframe.installIntoWindow(window)
    }
    
    func installLoginViewControllerIntoWindow(_ window: UIWindow) {
        let loginWireframe = container.resolve(LoginWireframe.self)!
        loginWireframe.installLoginToWindow(window)
    }
    
    func installUsernameSelectorViewControllerIntoWindow(_ window: UIWindow) {
        let loginWireframe = container.resolve(LoginWireframe.self)!
        loginWireframe.installUsernameSelectorToWindow(window)
    }
}
