//
//  AboutViewController.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian on 28/11/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController
{
    // MARK: Life Cycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.title = "About"
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
        textLabel.isHidden = false
        flowtoolzLabel.isHidden = false
        flowtoolzWebsiteLabel.isHidden = false
    }
    
    lazy var londonRealLogo: UIImageView =
    {
        // create
        let logo = UIImageView.newAutoLayout()
        self.view.addSubview(logo)
        
        // content
        logo.image = UIImage(named: "GuestImagePlaceholder")
        logo.contentMode = UIViewContentMode.scaleAspectFit

        // layout
        logo.autoPinEdge(toSuperviewEdge: .top, withInset: -30)
        logo.autoPinEdge(toSuperviewEdge: .left, withInset: 0)
        logo.autoSetDimension(.width, toSize: 500)
        logo.autoSetDimension(.height, toSize: 300)
        
        return logo
    }()
    
    lazy var textLabel: UILabel =
    {
        // create
        let view = UILabel.newAutoLayout()
        self.view.addSubview(view)
        
        // style
        view.font = UIFont.LondonRealLarge()
        view.textColor = UIColor.LondonRealUnfocusedText()
        view.numberOfLines = 0
        //view.textAlignment = NSTextAlignment.Center
        
        // content
        view.text = "London Real is the curator of people worth watching. We feature interesting guests with fascinating stories and unique perspectives on life. We aim to take viewers on a journey through the lives of others and ultimately inspire them to embark on one of their own.\n\nTired of being spoon-fed from the mainstream media, we’ve set out to offer a fresh, unscripted and unedited look into the world of real people. From activists to scientists, authors to fighters, politicians to drug smugglers – we present their real stories, uncensored and uncut.\n\nFounded in October 2011, London Real has filmed over 220 episodes, amassed over 300k total subscribers and been viewed over 65 million times.\n\nThe London Real TV app provides exclusive content. All copying and distribution is prohibited."
        
        // layout
        view.autoPinEdge(toSuperviewEdge: .top, withInset: 35)
        view.autoPinEdge(toSuperviewEdge: .right, withInset: LondonRealStyle.screenPaddingCGFloat)
        view.autoPinEdge(.left, to: .right, of: self.londonRealLogo, withOffset: 0)
        
        return view
    }()
    
    lazy var flowtoolzLabel: UILabel =
    {
        // create
        let view = UILabel.newAutoLayout()
        self.view.addSubview(view)
        
        // style
        view.font = UIFont.LondonRealLarge()
        view.textColor = UIColor.LondonRealUnfocusedText()
        view.textAlignment = NSTextAlignment.center
        
        // content
        view.text = "This app is made in Switzerland by"
        
        // layout
        view.autoPinEdge(.left, to: .left, of: self.textLabel)
        view.autoPinEdge(.top, to: .bottom, of: self.textLabel, withOffset: 55)
        
        return view
    }()
    
    lazy var flowtoolzWebsiteLabel: UILabel =
    {
        // create
        let view = UILabel.newAutoLayout()
        self.view.addSubview(view)
        
        // style
        view.font = UIFont.LondonRealHeadline()
        view.textColor = UIColor.LondonRealUnfocusedText()
        view.textAlignment = NSTextAlignment.center
        
        // content
        view.text = "Flowtoolz.com"
        
        // layout
        view.autoPinEdge(.left, to: .right, of: self.flowtoolzLabel, withOffset: 20)
        view.autoAlignAxis(.baseline, toSameAxisOf: self.flowtoolzLabel)
        
        return view
    }()
}
