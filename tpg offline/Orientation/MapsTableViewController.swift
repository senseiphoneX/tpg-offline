//
//  MapsTableViewController.swift
//  tpg offline
//
//  Created by Remy on 18/10/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

class OrientationTableViewController: UITableViewController {

    var maps: [String: UIImage] = [
        "Urban map".localized: #imageLiteral(resourceName: "urbainMap"),
        "Regional map".localized: #imageLiteral(resourceName: "periurbainMap"),
        "Noctambus urban map".localized: #imageLiteral(resourceName: "nocUrbainMap"),
        "Noctambus regional map".localized: #imageLiteral(resourceName: "nocPeriurbainMap")
    ]

    var titles = [
        "Urban map".localized,
        "Regional map".localized,
        "Noctambus urban map".localized,
        "Noctambus regional map".localized
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Orientation".localized
        if App.darkMode {
            self.navigationController?.navigationBar.barStyle = .black
            self.tableView.backgroundColor = .black
        } else {
            self.navigationController?.navigationBar.barStyle = .default
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
        }

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
        if App.darkMode {
            self.navigationController?.navigationBar.barStyle = .black
            self.tableView.backgroundColor = .black
        } else {
            self.navigationController?.navigationBar.barStyle = .default
        }
        self.navigationController?.navigationBar.barTintColor = nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? maps.count  : App.lines.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as? MapsTableViewControllerRow else {
                return UITableViewCell()
            }

            cell.titleLabel.text = titles[indexPath.row]
            cell.mapImage = self.maps[titles[indexPath.row]]

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "lineCell", for: indexPath) as? LineTableViewControllerRow else {
                return UITableViewCell()
            }
            cell.line = App.lines[indexPath.row]
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 190
        } else {
            return UITableViewAutomaticDimension
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            guard let destinationViewController = segue.destination as? MapViewController else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let row = tableView.cellForRow(at: indexPath) as? MapsTableViewControllerRow else { return }
            tableView.deselectRow(at: indexPath, animated: false)
            destinationViewController.mapImage = row.mapImage
            destinationViewController.title = row.titleLabel.text
        } else if segue.identifier == "showLine" {
            guard let destinationViewController = segue.destination as? LineViewController else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let row = tableView.cellForRow(at: indexPath) as? LineTableViewControllerRow else { return }
            tableView.deselectRow(at: indexPath, animated: false)
            destinationViewController.line = row.line
        }
    }
}

class MapsTableViewControllerRow: UITableViewCell {
    @IBOutlet private weak var mapImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!

    var mapImage: UIImage? {
        get {
            return mapImageView.image
        } set {
            mapImageView.image = newValue
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.textColor = App.textColor
        self.visualEffectView.effect = UIBlurEffect(style: App.darkMode ? .dark : .light)
        let view = UIView()
        view.backgroundColor = .clear
        self.selectedBackgroundView = view
    }
}

class LineTableViewControllerRow: UITableViewCell {
    var line: Line? {
        didSet {
            guard let line = self.line else { return }
            self.textLabel?.text = String(format: "Line %@".localized, line.line)
            if App.darkMode {
                self.backgroundColor = App.cellBackgroundColor
                self.textLabel?.textColor = App.color(for: line.line)
            } else {
                self.backgroundColor = App.color(for: line.line)
                self.textLabel?.textColor = App.color(for: line.line).contrast
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let view = UIView()
        view.backgroundColor = .clear
        self.selectedBackgroundView = view
    }
}
