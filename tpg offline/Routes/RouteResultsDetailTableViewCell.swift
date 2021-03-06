//
//  RouteResultDetailTableViewCell.swift
//  tpg offline
//
//  Created by Remy on 21/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

class RouteResultDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var lineBackgroundView: UIView!
    @IBOutlet weak var departureStopLabel: UILabel!
    @IBOutlet weak var departureHourLabel: UILabel!
    @IBOutlet weak var arrivalStopLabel: UILabel!
    @IBOutlet weak var arrivalHourLabel: UILabel!

    @IBOutlet var images: [UIImageView]!

    var section: RouteConnection.Sections? = nil {
        didSet {
            guard let section = section else { return }

            let destinationName = App.stops.filter({$0.nameTransportAPI == section.journey?.to})[safe: 0]?.name
                ?? (section.journey?.to ?? "#?!")

            self.lineLabel.text = String(format: "Line %@ - %@".localized, "\(section.journey?.lineCode ?? "#?!".localized)", "\(destinationName)")
            if section.journey?.compagny == "TPG" {
                self.lineBackgroundView.backgroundColor = App.darkMode ? App.cellBackgroundColor :
                    App.color(for: section.journey?.lineCode ?? "")
                self.lineLabel.textColor = App.darkMode ? App.color(for: section.journey?.lineCode ?? "") :
                    App.color(for: section.journey?.lineCode ?? "").contrast
            } else if section.journey?.compagny == "SBB" {
                self.lineLabel.text = String(format: "SBB %@ - %@".localized, "\(section.journey?.lineCode ?? "#?!".localized)",
                    "\(destinationName)")
                self.lineBackgroundView.backgroundColor = App.darkMode ? App.cellBackgroundColor : .red
                self.lineLabel.textColor = App.darkMode ? .red : .white
            } else {
                self.lineBackgroundView.backgroundColor = App.darkMode ? .black : .white
                self.lineLabel.textColor = App.darkMode ? .white : .black
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"

            departureStopLabel.text = (App.stops.filter({$0.sbbId == section.departure.station.id})[safe: 0]?.name)
                ?? section.departure.station.name
            departureHourLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970:
                TimeInterval(section.departure.departureTimestamp ?? 0)))
            arrivalStopLabel.text = (App.stops.filter({$0.sbbId == section.arrival.station.id})[safe: 0]?.name)
                ?? section.arrival.station.name
            arrivalHourLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970:
                TimeInterval(section.arrival.arrivalTimestamp ?? 0)))
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = App.cellBackgroundColor

        selectionStyle = .none
        departureStopLabel.textColor = App.textColor
        departureHourLabel.textColor = App.textColor
        arrivalStopLabel.textColor = App.textColor
        arrivalHourLabel.textColor = App.textColor

        for image in images {
            image.image = image.image?.maskWith(color: App.textColor)
        }
    }
}
