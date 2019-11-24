//
//  Helpers.swift
//  MVCDemo
//
//  Created by Manu Singh on 24/11/19.
//  Copyright © 2019 hackp93. All rights reserved.
//

import Foundation
import UIKit

func getInitialController(from storyboardId : String)->UIViewController?{
    let storyboard = UIStoryboard(name: storyboardId, bundle: nil)
    return storyboard.instantiateInitialViewController()
}
