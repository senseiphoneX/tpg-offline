
//
//  ArretsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/11/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import CoreLocation
import ChameleonFramework
import PermissionScope
import DGElasticPullToRefresh
import INTULocationManager
import Localize_Swift

class ArretsTableViewController: UITableViewController {
	var arretsLocalisation = [Arret]()
	var filtredResults = [Arret]()
	let searchController = UISearchController(searchResultsController: nil)
	let tpgUrl = tpgURL()
	let defaults = NSUserDefaults.standardUserDefaults()
	var arretsKeys: [String] = []
	let pscope = PermissionScope()
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let loadingView = DGElasticPullToRefreshLoadingViewCircle()
		loadingView.tintColor = AppValues.textColor
		
		tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
			
			self!.refresh(loadingView)
			self?.tableView.dg_stopLoading()
			
			}, loadingView: loadingView)
		
		tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
		tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
		
		// Result Search Controller
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		definesPresentationContext = true
		searchController.searchBar.placeholder = "Rechercher parmi les arrets".localized()
		
		arretsKeys = [String](AppValues.arrets.keys)
		arretsKeys.sortInPlace({ (string1, string2) -> Bool in
			let stringA = String((AppValues.arrets[string1]?.titre)! + (AppValues.arrets[string1]?.sousTitre)!)
			let stringB = String((AppValues.arrets[string2]?.titre)! + (AppValues.arrets[string2]?.sousTitre)!)
			if stringA.lowercaseString < stringB.lowercaseString {
				return true
			}
			return false
		})
		
		if #available(iOS 9.0, *) {
			if(traitCollection.forceTouchCapability == .Available){
				registerForPreviewingWithDelegate(self, sourceView: view)
			}
		}
		
		navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
		navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
		navigationController?.navigationBar.tintColor = AppValues.textColor
		tableView.backgroundColor = AppValues.primaryColor
		searchController.searchBar.barTintColor = AppValues.primaryColor
		searchController.searchBar.tintColor = AppValues.textColor
		tableView.tableHeaderView = self.searchController.searchBar
		
		switch PermissionScope().statusNotifications() {
		case .Unknown:
			// ask
			pscope.addPermission(NotificationsPermission(), message: "tpg offline a besoin des notifications pour vous envoyer des rappels.".localized())
		case .Unauthorized, .Disabled:
			// bummer
			return
		case .Authorized:
			// thanks!
			return
		}
		switch PermissionScope().statusLocationInUse() {
		case .Unknown:
			// ask
			pscope.addPermission(LocationWhileInUsePermission(), message: "tpg offline a de savoir où vous vous trouvez pour indiquer les arrets les plus proches.".localized())
		case .Unauthorized, .Disabled:
			// bummer
			return
		case .Authorized:
			// thanks!
			return
		}
		
		pscope.show({ finished, results in
			print("got results \(results)")
			}, cancelled: { (results) -> Void in
				print("thing was cancelled")
		})
		
		requestLocation()
	}
	
	func requestLocation() {
		
		var accurency = INTULocationAccuracy.Block
		if self.defaults.integerForKey("locationAccurency") == 1 {
			accurency = INTULocationAccuracy.House
		}
		else if self.defaults.integerForKey("locationAccurency") == 2 {
			accurency = INTULocationAccuracy.Room
		}
		
		let localisationManager = INTULocationManager.sharedInstance()
		localisationManager.requestLocationWithDesiredAccuracy(accurency, timeout: 10, delayUntilAuthorized: true) { (location, accurency, status) in
			if status == .Success {
				self.arretsLocalisation = []
				print("Résultat de la localisation")
				
				if self.defaults.integerForKey("proximityDistance") == 0 {
					self.defaults.setInteger(500, forKey: "proximityDistance")
				}
				
				for x in [Arret](AppValues.arrets.values) {
					x.distance = location.distanceFromLocation(x.location)
					
					if (location.distanceFromLocation(x.location) <= Double(self.defaults.integerForKey("proximityDistance"))) {
						
						self.arretsLocalisation.append(x)
						print(x.stopCode)
						print(String(location.distanceFromLocation(x.location)))
					}
				}
				self.arretsLocalisation.sortInPlace({ (arret1, arret2) -> Bool in
					if arret1.distance < arret2.distance {
						return true
					}
					else {
						return false
					}
				})
				self.tableView.reloadData()
			}
		}

	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
		navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
		navigationController?.navigationBar.tintColor = AppValues.textColor
		tableView.backgroundColor = AppValues.primaryColor
		searchController.searchBar.barTintColor = AppValues.primaryColor
		searchController.searchBar.tintColor = AppValues.textColor
		
		tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
		tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
		
		refresh(self)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
	}
	
	func refresh(sender:AnyObject)
	{
		requestLocation()
		tableView.reloadData()
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		if searchController.active {
			return 1
		}
		else {
			return 3
		}
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if searchController.active {
			return self.filtredResults.count
		}
		else {
			if section == 0 {
				return arretsLocalisation.count
			}
			else if section == 1 {
				if (AppValues.arretsFavoris == nil) {
					return 0
				}
				else {
					return AppValues.arretsFavoris.count
				}
			}
			else {
				return AppValues.arrets.count
			}
		}
	}
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if !searchController.active {
			let cell = tableView.dequeueReusableCellWithIdentifier("arretsCell", forIndexPath: indexPath)
			if indexPath.section == 0 {
				let iconLocation = FAKFontAwesome.locationArrowIconWithSize(20)
				iconLocation.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
				cell.accessoryView = UIImageView(image: iconLocation.imageWithSize(CGSize(width: 20, height: 20)))
				cell.textLabel?.text = arretsLocalisation[indexPath.row].nomComplet
				cell.detailTextLabel!.text = "~" + String(Int(arretsLocalisation[indexPath.row].distance!)) + "m"
			}
			else if indexPath.section == 1 {
				let iconFavoris = FAKFontAwesome.starIconWithSize(20)
				iconFavoris.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
				cell.accessoryView = UIImageView(image: iconFavoris.imageWithSize(CGSize(width: 20, height: 20)))
				cell.textLabel?.text = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[indexPath.row]]?.titre
				cell.detailTextLabel?.text = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[indexPath.row]]?.sousTitre
			}
			else {
				let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
				iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
				cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
				cell.textLabel?.text = AppValues.arrets[arretsKeys[indexPath.row]]!.titre
				cell.detailTextLabel!.text = AppValues.arrets[arretsKeys[indexPath.row]]!.sousTitre
			}
			
			let backgroundView = UIView()
			backgroundView.backgroundColor = AppValues.secondaryColor
			cell.selectedBackgroundView = backgroundView
			cell.backgroundColor = AppValues.primaryColor
			cell.textLabel?.textColor = AppValues.textColor
			cell.detailTextLabel?.textColor = AppValues.textColor
			
			return cell
			
		}
		else {
			let cell = tableView.dequeueReusableCellWithIdentifier("arretsCell", forIndexPath: indexPath)
			let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
			iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
			
			let backgroundView = UIView()
			backgroundView.backgroundColor = AppValues.secondaryColor
			cell.selectedBackgroundView = backgroundView
			cell.textLabel?.text = filtredResults[indexPath.row].titre
			cell.textLabel?.textColor = AppValues.textColor
			cell.detailTextLabel!.text = filtredResults[indexPath.row].sousTitre
			cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
			cell.backgroundColor = AppValues.primaryColor
			
			return cell
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "afficherProchainsDeparts") {
			let departsArretsViewController:DepartsArretTableViewController = (segue.destinationViewController) as! DepartsArretTableViewController
			if searchController.active {
				departsArretsViewController.arret = filtredResults[(tableView.indexPathForSelectedRow?.row)!]
			}
			else {
				if tableView.indexPathForSelectedRow!.section == 0 {
					departsArretsViewController.arret = arretsLocalisation[tableView.indexPathForSelectedRow!.row]
				}
				else if tableView.indexPathForSelectedRow!.section == 1 {
					departsArretsViewController.arret = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[tableView.indexPathForSelectedRow!.row]]
				}
				else {
					departsArretsViewController.arret = AppValues.arrets[self.arretsKeys[(tableView.indexPathForSelectedRow?.row)!]]
				}
			}
		}
	}
	
	deinit {
		tableView.dg_removePullToRefresh()
	}
	
	func filterContentForSearchText(searchText: String) {
		filtredResults = [Arret](AppValues.arrets.values).filter { arret in
			return arret.nomComplet.lowercaseString.containsString(searchText.lowercaseString)
		}
		filtredResults.sortInPlace { (arret1, arret2) -> Bool in
			let stringA = String(arret1.titre + arret1.sousTitre)
			let stringB = String(arret2.titre + arret2.sousTitre)
			if stringA.lowercaseString < stringB.lowercaseString {
				return true
			}
			return false
		}
		
		tableView.reloadData()
	}
}

extension ArretsTableViewController: UISearchResultsUpdating {
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		filterContentForSearchText(searchController.searchBar.text!)
	}
}

extension ArretsTableViewController : UIViewControllerPreviewingDelegate {
	func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		
		guard let indexPath = tableView.indexPathForRowAtPoint(location) else { return nil }
		
		guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return nil }
		
		guard let detailVC = storyboard?.instantiateViewControllerWithIdentifier("departsArretTableViewController") as? DepartsArretTableViewController else { return nil }
		
		if searchController.active {
			detailVC.arret = filtredResults[indexPath.row]
		}
		else {
			if indexPath.section == 0 {
				detailVC.arret = arretsLocalisation[indexPath.row]
			}
			else if indexPath.section == 1 {
				detailVC.arret = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[indexPath.row]]
			}
			else {
				detailVC.arret = AppValues.arrets[self.arretsKeys[indexPath.row]]
			}
		}
		if #available(iOS 9.0, *) {
			previewingContext.sourceRect = cell.frame
		}
		return detailVC
	}
	
	func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
		
		showViewController(viewControllerToCommit, sender: self)
		
	}
}