//
//  FeedbackViewController.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian on 28/11/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController
{
    // MARK: Life Cycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.title = "Feedback"
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // style
        view.backgroundColor = UIColor.LondonRealBackground()
        
        // show views
        titleLabel.isHidden = false
        textLabel.isHidden = false
    }
    
    lazy var titleLabel: UILabel =
    {
        // create
        let view = UILabel.newAutoLayout()
        self.view.addSubview(view)
        
        // style
        view.font = UIFont.LondonRealHeadline()
        view.textColor = UIColor.LondonRealUnfocusedText()
        view.textAlignment = NSTextAlignment.center
        
        // content
        view.text = "We Want You !"
        
        // layout
        var insets = UIEdgeInsets(inset: LondonRealStyle.screenPaddingCGFloat)
        insets.top = 250
        view.autoPinEdgesToSuperviewEdges(with: insets, excludingEdge: .bottom)
        
        return view
    }()
    
    lazy var textLabel: UILabel =
    {
        // create
        let view = UILabel.newAutoLayout()
        self.view.addSubview(view)
        
        // style
        view.font = UIFont.LondonRealLarge()
        view.textColor = UIColor.LondonRealUnfocusedText()
        view.textAlignment = NSTextAlignment.center
        view.numberOfLines = 0
        
        // content
        view.text = "We just started building the London Real TV app and we improve it continuously.\nYou can make the app better by shooting us a message with your feedback.\nWe read and consider all your thoughts and criticism. Promise.\n\napp@londonrealacademy.com"
        
        // layout
        view.autoPinEdge(toSuperviewEdge: .left, withInset: LondonRealStyle.screenPaddingCGFloat)
        view.autoPinEdge(toSuperviewEdge: .right, withInset: LondonRealStyle.screenPaddingCGFloat)
        view.autoPinEdge(.top, to: .bottom, of: self.titleLabel, withOffset: 70)
        
        return view
    }()
}
