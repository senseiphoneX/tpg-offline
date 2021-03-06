//
//  StopsTableViewself.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 29/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import UIKit

class StopsTableViewCell: UITableViewCell {
    var stop: Stop?
    var isFavorite: Bool = false
    var isNearestStops: Bool = false

    func configure(with stop: Stop) {
        self.stop = stop
        self.accessoryView = UIImageView(image: #imageLiteral(resourceName: "next").maskWith(color: #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)))
        self.backgroundColor = .white

        if App.darkMode {
            self.accessoryView = UIImageView(image: #imageLiteral(resourceName: "next").maskWith(color: .white))
            self.backgroundColor = App.cellBackgroundColor
            let selectedView = UIView()
            selectedView.backgroundColor = .black
            self.selectedBackgroundView = selectedView
        }

        let titleAttributes: [NSAttributedStringKey: Any]
        let subtitleAttributes: [NSAttributedStringKey: Any]
        if stop.subTitle != "", !isNearestStops {
            titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .subheadline),
                               NSAttributedStringKey.foregroundColor: App.textColor] as [NSAttributedStringKey: Any]
            subtitleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline),
                                  NSAttributedStringKey.foregroundColor: App.textColor] as [NSAttributedStringKey: Any]
        } else {
            titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline),
                                   NSAttributedStringKey.foregroundColor: App.textColor] as [NSAttributedStringKey: Any]
            subtitleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .subheadline),
                                      NSAttributedStringKey.foregroundColor: App.textColor] as [NSAttributedStringKey: Any]
        }
        self.textLabel?.numberOfLines = 0
        self.detailTextLabel?.numberOfLines = 0

        self.textLabel?.attributedText = NSAttributedString(string: stop.title, attributes: titleAttributes)
        self.detailTextLabel?.attributedText = NSAttributedString(string: stop.subTitle, attributes: subtitleAttributes)

        if isNearestStops {
            self.textLabel?.attributedText = NSAttributedString(string: stop.name, attributes: titleAttributes)
            let walkDuration = Int(stop.distance / 1000 / 5 * 60)
            let walkDurationString = walkDuration == 0 ? String(format: "%@m".localized, "\(Int(stop.distance))"):
                String(format: "%@m (~%@ minutes)".localized, "\(Int(stop.distance))", "\(walkDuration)")
            self.detailTextLabel?.attributedText = NSAttributedString(string: walkDurationString, attributes: subtitleAttributes)
            self.detailTextLabel?.accessibilityLabel = walkDuration == 0 ?
                String(format: "%@m".localized, "\(Int(stop.distance))"):
                String(format: "%@ meters, about %@ minutes to walk".localized, "\(Int(stop.distance))", "\(walkDuration)")
        }
    }
}
