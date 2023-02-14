//
//  ViewController.swift
//  BeGo Everyday
//
//  Created by yoonbumtae on 2023/02/10.
//

import UIKit
import CoreLocation
import SPAlert

class ViewController: UIViewController {

    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var lblCalendarTitle: UILabel!
    @IBOutlet weak var lblDistanceToTarget: UILabel!
    
    private var calendarData: CalendarData!
    private var accessRecordManager = AccessRecordManager()
    private let calendar = Calendar(identifier: .gregorian)
    
    private let locationManager = GPSLocationManager()
    /// 목표 영역 안으로 들어온 상태, 벗어나면 토글
    private var isEnteredTargetArea = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch locationManager.authStatus {
        case .notDetermined, .authorizedAlways, .authorizedWhenInUse:
            locationManager.instantStartUpdatingLocation(delegateTo: self)
        case .restricted:
            break
        case .denied:
            break
        @unknown default:
            break
        }
        
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        
        calendarData = CalendarData(baseDate: Date(), changedBaseDateHandler: { date in
            
            self.calendarCollectionView.reloadData()
            self.lblCalendarTitle.text = self.calendarData.localizedCalendarTitle
        })
        
        lblCalendarTitle.text = calendarData.localizedCalendarTitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            
            // print(calendarData.days[indexPath.row].date, accessRecordManager.findAccessDateComponents(component), "||", isAccessedBeforeDay, isAccessedAfterDay)
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

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        
        guard let savedCoordinate = loadCoordFromUserDefaults() else {
            return
        }
        
        // 현재 위치 업데이트 (정보만)
        let coord0 = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let coord1 = CLLocation(latitude: savedCoordinate.latitude, longitude: savedCoordinate.longitude)
        let distance = coord0.distance(from: coord1)
        
        lblDistanceToTarget.text = String(format: "Distance(m): %.2f", distance)
        
        let currentlyTargetEntered = distance < 30
        if !isEnteredTargetArea && currentlyTargetEntered {
            // popup message
            let alertView = SPAlertView(title: "장소에 도착함", message: "잘 했어요!", preset: .custom(UIImage(named: "mountain.2.fill")!))
            alertView.backgroundColor = .green
            alertView.present(haptic: .success, completion: nil)
            
            AccessRecordManager.addCurrentDate()
            accessRecordManager = AccessRecordManager()
            calendarCollectionView.reloadData()
            
            isEnteredTargetArea = true
        } else if isEnteredTargetArea && !currentlyTargetEntered {
            isEnteredTargetArea = false
        }
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
        lblNumber.layoutIfNeeded()
        let yMargin: CGFloat = 20
        
        if shape == .standalone {
            let width = self.frame.width * 0.65
            let x = (self.frame.width - width) / 2
            viewPlant.frame = CGRect(x: x, y: lblNumber.frame.maxY + yMargin, width: width, height: 10)
        } else {
            let marginX: CGFloat = 10
            let x: CGFloat = shape == .leftStart ? marginX : 0
            let width: CGFloat = self.frame.width - (shape == .rightEnd ? marginX : 0)
            viewPlant.frame = CGRect(x: x, y: lblNumber.frame.maxY + yMargin, width: width, height: 10)
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
