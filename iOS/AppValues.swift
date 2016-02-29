//
//  AppValues.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 09/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit

struct AppValues {
    static var arrets: [String: Arret] = [:]
    static var arretsFavoris: [String: Arret]!  = [:]
    static var nomCompletsFavoris: [String]!  = []
	static var favorisItineraires: [[Arret]]! = []
	
    static var primaryColor: UIColor! = UIColor.flatOrangeColor()
    static var secondaryColor: UIColor! = UIColor.flatOrangeColorDark()
    static var textColor: UIColor! = UIColor.whiteColor()
	static var premium: Bool! = false
}