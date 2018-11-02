//
//  UseCasesSystem.swift
//  XCodeProjectIOS
//
//  Created by Sebastian Fichtner on 06/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import Foundation

class UseCasesSystem : NSObject
{
    // MARK: Singleton Access
    
    public static let sharedInstance = UseCasesSystem()
    
    override private init()
    {
        super.init()
        
        initialize()
    }
    
    // MARK: Initialization
    
    public static func makeSureInstanceExists()
    {
        print("making sure shared instance exists: \(sharedInstance.description)")
    }
    
    private func initialize()
    {
        UseCasesModel.makeSureInstanceExists()
        DomainSystem.makeSureInstanceExists()
    }
}
