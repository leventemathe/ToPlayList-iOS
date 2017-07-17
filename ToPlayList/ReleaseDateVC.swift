//
//  ReleaseDateVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 07. 16..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

struct ReleaseDateSection {
    
    var releaseDates: [ReleaseDate]
    let region: Region
}

class ReleaseDateVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var didSetHeightDelegate: DidSetHeightDelegate?
    
    private var releaseDateSections = [ReleaseDateSection]() {
        didSet {
            tableView.reloadData()
            setHeight()
        }
    }
    
    private let HEADER_HEIGHT = CGFloat(25.0)
    
    func setHeight() {
        var height = CGFloat(0.0)
        for seciton in releaseDateSections {
            height += HEADER_HEIGHT
            for _ in seciton.releaseDates {
                height += tableView.rowHeight
            }
        }
        didSetHeightDelegate?.didSet(height: height)
    }
    
    func setReleaseDates(_ releaseDates: [ReleaseDate]) {
        var result = [ReleaseDateSection]()
        let datesGroupedByRegion = releaseDates.sorted(by: { $0.region.id <= $1.region.id })
        var region: Region? = nil
        for date in datesGroupedByRegion {
            if date.region != region {
                region = date.region
                result.append(ReleaseDateSection(releaseDates: [ReleaseDate](), region: region!))
            }
            result[result.count - 1].releaseDates.append(date)
        }
        releaseDateSections = sortSectionsByDate(result)
    }
    
    private func sortSectionsByDate(_ sections: [ReleaseDateSection]) -> [ReleaseDateSection] {
        var sortedSubDatesSections = [ReleaseDateSection]()
        for section in sections {
            let sortedDates = section.releaseDates.sorted(by: { $0.date <= $1.date })
            let newSection = ReleaseDateSection(releaseDates: sortedDates, region: section.region)
            sortedSubDatesSections.append(newSection)
        }
        return sortedSubDatesSections.sorted(by: { $0.releaseDates[0].date <= $1.releaseDates[0].date })
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return releaseDateSections[section].releaseDates.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return releaseDateSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ReleaseDateCell.reuseIdentifier) as? ReleaseDateCell {
            cell.update(releaseDateSections[indexPath.section].releaseDates[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as! HeaderView
        headerView.layer.masksToBounds = true
        headerView.addRoundedCorners(HEADER_HEIGHT / 2.0)
        headerView.label.text = releaseDateSections[section].region.name
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HEADER_HEIGHT
    }
}
