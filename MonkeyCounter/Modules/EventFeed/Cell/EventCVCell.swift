//
//  EventCVCell.swift
//  MonkeyCounter
//
//  Created by AT on 9/19/16.
//  Copyright © 2016 AT. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

class EventCVCell: UICollectionViewCell {
    
    enum SwipeType {
        case Left
        case Right
        case LeftMargin
        case RightMargin
        case None
    }
    
    /*
     *  cccc   tttttttttttt         .
     *  cccc   tttttttttttt         .
     *  cccc   tttttttttttt         .
     *
     */
    
    /// Approximate height for the cell.
    ///
    /// - Parameter width: Cell width.
    /// - Returns: return approximate height for the cell.
    public func heightForWidth(_ width: CGFloat) -> CGFloat {
        return 80.0
    }
    
    /// Cell re-use identifier
    public var identifier: String { return EventCVCell.className }
    
    /// Called on a cell swipe
    public var swiped: ((SwipeType) -> (Void))? = nil
    
    /// Called on a more button tap
    public var moreTapped: ((Void) -> (Void))? = nil
    
    fileprivate let countLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption2)
        label.textColor = UIColor.flatWhite
        label.numberOfLines = 0
        label.text = "--"
        label.textAlignment = .center
        
        label.layer.cornerRadius = Const.countLabelSize / 2
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.borderColor = UIColor.flatPurple.cgColor
        label.layer.borderWidth = 2.0
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let textLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        label.textColor = UIColor.flatWhite
        label.numberOfLines = 0
        label.text = "Event name..."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let moreButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor =  UIColor.clear
        
        button.clipsToBounds = true
        button.setImage(AppImages.more, for: UIControlState.normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    fileprivate var originalCenter = CGPoint()
    fileprivate var originalFrame = CGRect()
    fileprivate var originalColor = UIColor.black
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addViews()
        
        self.backgroundColor = UIColor.flatYellowDark
    }
    
    public func updateWith(count: Int64, text: String?) {
        self.countLabel.text = (count > 0) ? String(count) : "--"
        self.textLabel.text = text
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    fileprivate func addViews() {
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        recognizer.delegate = self
        self.addGestureRecognizer(recognizer)
//        let titleRecognizer = UITapGestureRecognizer(target: self, action:#selector(titleLabelTapped))
//        self.titleLabel.isUserInteractionEnabled = true
//        self.titleLabel.addGestureRecognizer(titleRecognizer)
//        
        //        self.adjustWidth(self.contentView.bounds.size.width)
        
        let pressedAction = Action<Void, Void, NoError> { value in SignalProducer.empty }
        self.moreButton.reactive.pressed = CocoaAction(pressedAction) { button in
            if let moreTapped = self.moreTapped {
                moreTapped()
            }
        }
        
        self.contentView.addSubview(self.countLabel)
        self.contentView.addSubview(self.textLabel)
        self.contentView.addSubview(self.moreButton)
        
        NSLayoutConstraint.activate([
            self.countLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 2),
            self.countLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0),
            self.countLabel.widthAnchor.constraint(equalToConstant: Const.countLabelSize),
            self.countLabel.heightAnchor.constraint(equalToConstant: Const.countLabelSize),
            
            self.countLabel.rightAnchor.constraint(equalTo: self.textLabel.leftAnchor, constant: -10),
            
            self.textLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 2),
            self.textLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -2),
            
            self.textLabel.rightAnchor.constraint(equalTo: self.moreButton.leftAnchor, constant: -5),
            
            self.moreButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0),
            self.moreButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -12),
            ])
        
    }

}

// MARK:- Swipe left/right handling
extension EventCVCell {
    func handlePan(recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == .began {
            originalCenter = center
            originalFrame = frame
            originalColor = self.backgroundColor!
        }
        
        // shift will change from -2 to 2
        // it is negative if we move the cell right
        // and positive if we move left
        let shift = (originalCenter.x - center.x) / originalCenter.x
        //        print("ratio \(ratio) cx \(center.x) ox \(originalCenter.x)")
        
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            center = CGPoint(x:originalCenter.x + translation.x, y: originalCenter.y)
            self.backgroundColor = self.colorForShift(shift: shift)
        }
        
        if recognizer.state == .ended {
            
            let swipeType = swipeTypeFor(shift: shift)
            
            UIView.animate(withDuration: 0.2,
                           animations: {
                            self.frame = self.originalFrame
                            self.backgroundColor = self.originalColor
            }, completion: { (success) in
                if let swiped = self.swiped {
                    swiped(swipeType)
                }
            })
        }
    }
    
    // MARK :- private stuff
    fileprivate struct Const {
        static let rightShiftStart:CGFloat  = -0.7
        static let rightShiftEnd:CGFloat    = -1.6
        static let leftShiftStart:CGFloat   = 0.7
        static let leftShiftEnd:CGFloat     = 1.6
        
        static let countLabelSize:CGFloat   = 50.0
    }
    
    /// Determine the swipe type from the shift
    ///
    /// - Parameter shift: cell shift from center
    /// - Returns: enum describing the swipe time
    private func swipeTypeFor(shift: CGFloat) -> SwipeType {
        if shift < Const.rightShiftStart {
            if shift > Const.rightShiftEnd {
                return SwipeType.Right
            } else {
                return SwipeType.RightMargin
            }
        } else if shift > Const.leftShiftStart {
            if shift < Const.leftShiftEnd {
                return SwipeType.Left
            } else {
                return SwipeType.LeftMargin
            }
        }
        return SwipeType.None
    }
    
    /**
     *
     *  Create a gradient effect for cell background color
     *
     *
     */
    private func colorForShift(shift: CGFloat) -> UIColor {
        let swipeType = swipeTypeFor(shift: shift)
        switch swipeType {
        case .Left:
            // blue
            let delta = abs(shift - Const.leftShiftStart) * 100
            return UIColor(red: 32.0 / 255, green: 17.0 / 255, blue: (320.0 - delta)  / 255, alpha: 1.0)
        case .LeftMargin:
            // red
            let delta = abs(shift - Const.rightShiftStart) * 100
            return UIColor(red: (242.0 + delta)  / 255, green: 19.0 / 255, blue:  34.0 / 255, alpha: 1.0)
        case .Right:
            // green
            let delta = abs(shift - Const.rightShiftStart) * 100
            return UIColor(red: 34.0 / 255, green: (180.0 + delta) / 255, blue:  154.0 / 255, alpha: 1.0)
        case .RightMargin:
            // red
            let delta = abs(shift - Const.leftShiftStart) * 100
            return UIColor(red: (242.0 + delta)  / 255, green: 19.0 / 255, blue:  34.0 / 255, alpha: 1.0)
        case .None:
            return self.originalColor
        }
    }
}

// MARK:- UIGestureRecognizerDelegate
extension EventCVCell: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
}
