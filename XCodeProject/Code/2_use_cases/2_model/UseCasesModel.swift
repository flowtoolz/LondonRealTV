//
//  UseCasesModel.swift
//  XCodeProjectIOS
//
//  Created by Sebastian Fichtner on 06/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import Foundation

class UseCasesModel : NSObject
{
    // MARK: Singleton Access
    
    public static let sharedInstance = UseCasesModel()
    
    override private init()
    {
        super.init()
        
        initialize()
    }
    
    // MARK: initialization
    
    public static func makeSureInstanceExists()
    {
        print("making sure shared instance exists: \(sharedInstance.description)")
    }
    
    private func initialize()
    {
        DomainModel.makeSureInstanceExists()
    }
}
