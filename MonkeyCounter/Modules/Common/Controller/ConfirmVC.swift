//
//  ConfirmVC.swift
//  MonkeyCounter
//
//  Created by AT on 6/21/17.
//  Copyright © 2017 AT. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

class ConfirmVC: UIViewController, Explodable {
    
    /// Called on a confirm or decline button tap
    public var confirmed: ((Bool) -> (Void))? = nil

    
    internal var text:String? {
        didSet {
            self.textLabel.text = text
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        
        self.view = UIView()
        self.view.backgroundColor = .flatPurple
        
        self.addViews()
    }
    
    // MARK:- private stuff
    fileprivate let directions = [ExplodeDirection.top, ExplodeDirection.bottom, ExplodeDirection.left, ExplodeDirection.right, ExplodeDirection.chaos]
    
    fileprivate func addViews() {
        self.view.addSubview(self.backgroundImage)
        self.view.addSubview(self.verStackView)
        
        let height = UIScreen.main.bounds.height * 0.3
        
        NSLayoutConstraint.activate([
            self.backgroundImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            self.backgroundImage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
            
            self.verStackView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            self.verStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            self.verStackView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            self.verStackView.heightAnchor.constraint(equalToConstant: height),
            
            ])
        
        self.verStackView.addArrangedSubview(self.textLabel)
        self.verStackView.addArrangedSubview(self.horStackView)
        
        self.horStackView.addArrangedSubview(self.confirmButton)
        self.horStackView.addArrangedSubview(self.declineButton)
        
        // confirmed
        let pressedActionConfirm = Action<Void, Void, NoError> { value in SignalProducer.empty }
        self.confirmButton.reactive.pressed = CocoaAction(pressedActionConfirm) { button in
            let randomDirection = Int(arc4random_uniform(UInt32(4 - 0)) + 0)
            let direction = self.directions[randomDirection]
            
            self.backgroundImage.explode(direction, duration: 1) {
                
                self.dismiss(animated: true)
                if let confirmed = self.confirmed {
                    confirmed(true)
                }
                
            }
        }
        
        // declined
        let pressedActionDecline = Action<Void, Void, NoError> { value in SignalProducer.empty }
        self.declineButton.reactive.pressed = CocoaAction(pressedActionDecline) { button in
            
            self.dismiss(animated: true)
            if let confirmed = self.confirmed {
                confirmed(false)
            }
        }
        
    }
    
    fileprivate let backgroundImage: UIImageView = {
        let imageView = UIImageView(image: AppImages.dogBackground)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.flatPurple
        
        return imageView
    }()
    
    fileprivate let horStackView: UIStackView = {
        let sv = UIStackView()
        
        sv.axis  = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillProportionally
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        return sv
    }()
    
    fileprivate let verStackView: UIStackView = {
        let sv = UIStackView()
        
        sv.axis  = .vertical
        sv.alignment = .fill
        sv.distribution = .fillProportionally
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        return sv
    }()
    
    fileprivate let confirmButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor =  UIColor(white: 0, alpha: 0.3)
        
        button.clipsToBounds = true
        button.setTitle("Do it!", for: .normal)
        button.setTitleColor(UIColor.flatRed, for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    fileprivate let declineButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor =  UIColor(white: 0, alpha: 0.3)
        
        button.clipsToBounds = true
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor.flatWhiteDark, for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    fileprivate let textLabel: PaddingLabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        label.textColor = UIColor.flatWhite
        label.numberOfLines = 0
        label.text = "--"
        label.textAlignment = .center
        label.backgroundColor =  UIColor(white: 0, alpha: 0.3)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}
