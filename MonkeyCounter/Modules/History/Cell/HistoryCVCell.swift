//
//  HistoryCVCell.swift
//  MonkeyCounter
//
//  Created by AT on 6/13/17.
//  Copyright © 2016 AT. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

class HistoryCVCell: UICollectionViewCell {
    
    enum SwipeType {
        case Left
        case Right
        case LeftMargin
        case RightMargin
        case None
    }
    
    /*
     *
     *  dddd   tttt
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
    
    
    fileprivate let horStackView: UIStackView = {
        let sv = UIStackView()
        
        sv.axis  = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillProportionally
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        return sv
    }()
    
    fileprivate let dateLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        label.textColor = UIColor.flatWhite
        label.numberOfLines = 1
        label.text = "--"
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let dayOfWeekLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption2)
        label.textColor = UIColor.flatWhite
        label.numberOfLines = 1
        label.text = "--"
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    fileprivate let timeLabel: UILabel = {
        let label = UILabel()
        
        label.backgroundColor = UIColor.clear
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        label.textColor = UIColor.flatWhite
        label.numberOfLines = 1
        label.text = "--"
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addViews()
        
        self.backgroundColor = UIColor.flatYellowDark
    }
    
    public func updateWith(date: Date) {
        
        self.timeLabel.text = date.hourMinute()
        self.dateLabel.text = date.dayOfWeekMonthDay()
        self.dayOfWeekLabel.text = date.dayOfWeek()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    fileprivate func addViews() {
        
        self.contentView.addSubview(self.horStackView)
        
        NSLayoutConstraint.activate([
            self.horStackView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 2),
            self.horStackView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -2),
            self.horStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 2),
            self.horStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -2),
            
            ])
        
        self.horStackView.addArrangedSubview(self.dayOfWeekLabel)
        self.horStackView.addArrangedSubview(self.timeLabel)
        self.horStackView.addArrangedSubview(self.dateLabel)
    }

}
