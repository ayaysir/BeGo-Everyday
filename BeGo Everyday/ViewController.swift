//
//  ViewController.swift
//  BeGo Everyday
//
//  Created by yoonbumtae on 2023/02/10.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var lblCalendarTitle: UILabel!
    
    private var calendarData: CalendarData!
    private var accessRecordManager = AccessRecordManager()
    private let calendar = Calendar(identifier: .gregorian)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        
        calendarData = CalendarData(baseDate: Date(), changedBaseDateHandler: { date in
            
            self.calendarCollectionView.reloadData()
            self.lblCalendarTitle.text = self.calendarData.localizedCalendarTitle
        })
        
        lblCalendarTitle.text = calendarData.localizedCalendarTitle
    }

    @IBAction func btnActPrevMonth(_ sender: Any) {
        calendarData.moveMonth(value: -1)
    }
    
    @IBAction func btnActNextMonth(_ sender: Any) {
        calendarData.moveMonth(value: 1)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        calendarData.days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as? DayCell else {
            fatalError("Cell is not initialized.")
        }
        
        let dayObj = calendarData.days[indexPath.row]
        cell.configure(day: dayObj)
        
        let component = dayObj.date.get(.year, .month, .day)
        if let accessRecordManager = accessRecordManager, accessRecordManager.findAccessDateComponents(component) {
            var isAccessedBeforeDay: Bool {
                if indexPath.row == 0 {
                    if let beforeFirstDay = calendar.date(byAdding: .day, value: -1, to: dayObj.date)?.get(.year, .month, .day) {
                        return accessRecordManager.findAccessDateComponents(beforeFirstDay)
                    }
                }
                
                return accessRecordManager.findAccessDateComponents(
                    calendarData.days[indexPath.row - 1].date.get(.year, .month, .day))
            }
            
            var isAccessedAfterDay: Bool {
                if indexPath.row == calendarData.days.count - 1 {
                    if let afterLastDay = calendar.date(byAdding: .day, value: +1, to: dayObj.date)?.get(.year, .month, .day) {
                        return accessRecordManager.findAccessDateComponents(afterLastDay)
                    }
                }
                
                return accessRecordManager.findAccessDateComponents(
                    calendarData.days[indexPath.row + 1].date.get(.year, .month, .day))
            }
            
            /*
             isAccessedBeforeDay | isAccessedAfterDay
             leftStart: false true
             rightEnd: true false
             standalone: false false
             fillLine: true true
             */
            
            switch (isAccessedBeforeDay, isAccessedAfterDay) {
            case (false, true):
                cell.plantAccessRecord(shape: .leftStart)
            case (true, false):
                cell.plantAccessRecord(shape: .rightEnd)
            case (false, false):
                cell.plantAccessRecord(shape: .standalone)
            case (true, true):
                cell.plantAccessRecord(shape: .fillLine)
            }
            
            print(calendarData.days[indexPath.row].date, accessRecordManager.findAccessDateComponents(component), "||", isAccessedBeforeDay, isAccessedAfterDay)
        } else {
            cell.plantAccessRecord(shape: .none)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return  collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CalendarHeaderView", for: indexPath)
        default:
            fatalError("Not allowed.")
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = calendarCollectionView.frame.width / 7
        let height = Int(calendarCollectionView.frame.height - 50) / calendarData.numberOfWeeksInBaseDate
        
        return CGSize(width: width, height: CGFloat(height))
    }
}

class DayCell: UICollectionViewCell {
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var viewPlant: GrassView!
    
    enum GrassShape {
        case none
        case standalone
        case leftStart
        case rightEnd
        case fillLine
    }
    
    var isAccessed = false
    
    func configure(day: Day) {
        lblNumber.textColor = day.isWithinDisplayedMonth ? .label : .systemGray3
        lblNumber.text = "\(day.number)"
        self.backgroundColor = day.isSelected ? .systemGray5 : nil
    }
    
    func plantAccessRecord(shape: GrassShape) {
        viewPlant.layoutIfNeeded()
        
        if shape == .standalone {
            viewPlant.transform = CGAffineTransform(scaleX: 0.6, y: 1)
        } else {
            viewPlant.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
            
        let radius: CGFloat = shape == .standalone ? 10 : 5
        
        switch shape {
        case .standalone:
            viewPlant.roundCorners(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight,], radius: radius)
        case .leftStart:
            viewPlant.roundCorners(corners: [.topLeft, .bottomLeft,], radius: radius)
        case .rightEnd:
            viewPlant.roundCorners(corners: [.topRight, .bottomRight,], radius: radius)
        case .fillLine, .none:
            viewPlant.roundCorners(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight,], radius: 0.0)
        }
        
        if shape == .none {
            viewPlant.isHidden = true
            isAccessed = false
        } else {
            viewPlant.isHidden = false
            isAccessed = true
        }
    }
}
