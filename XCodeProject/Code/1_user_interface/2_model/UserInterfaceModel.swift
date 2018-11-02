//
//  UserInterfaceModel.swift
//  XCodeProjectIOS
//
//  Created by Sebastian Fichtner on 06/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import Foundation

class UserInterfaceModel: NSObject
{
    // MARK: Singleton Access
    
    public static let sharedInstance = UserInterfaceModel()
    
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
    }
}
