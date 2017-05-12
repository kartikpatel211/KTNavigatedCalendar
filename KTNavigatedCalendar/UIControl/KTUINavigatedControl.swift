//
//  KTUINavigatedControl.swift
//  KTNavigatedCalendar
//
//  Created by Kartik Patel on 5/6/17.
//  Copyright © 2017 KTPatel. All rights reserved.
//

import UIKit

enum dateType {
    case day
    case week
    case month
    case year
}

class RangeTimeInteval{
    var start : TimeInterval?
    var end : TimeInterval?
    
    init(startTimeInteval: TimeInterval, endTimeInterval: TimeInterval) {
        start = startTimeInteval
        end = endTimeInterval
    }
}

extension Date {
    
    func isBetweeen(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self) == self.compare(date2)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    struct Gregorian {
        static var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    }
    
    func dateAt(hours: Int, minutes: Int, second: Int) -> Date {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        //get the month/day/year componentsfor today's date.
        var date_components = calendar.components(
            [NSCalendar.Unit.year,
             NSCalendar.Unit.month,
             NSCalendar.Unit.day],
            from: self)
        
        //Create an NSDate for the specified time today.
        date_components.hour = hours
        date_components.minute = minutes
        date_components.second = second
        
        let newDate = calendar.date(from: date_components)!
        return newDate
    }
    
    func getStratTimeInterval() -> TimeInterval{
        return dateAt(hours: 0, minutes: 0, second: 0).timeIntervalSince1970
    }
    
    func getEndTimeInterval() -> TimeInterval{
        return dateAt(hours: 23, minutes: 59, second: 59).timeIntervalSince1970
    }
    
    func startOfWeek(weekday: Int) -> Date {
        var comp: DateComponents =  Gregorian.calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: self)
        comp.weekday = weekday // 2 = Monday
        return  Gregorian.calendar.date(from: comp)!
    }
    
    func endOfWeek(weekday: Int) -> Date {
        var comp: DateComponents = DateComponents()
        comp.day = 7
        comp.second = -1
        return Gregorian.calendar.date(byAdding: comp, to: startOfWeek(weekday: weekday), wrappingComponents: false)!
    }
    
    func startOfMonth() -> Date {
        let components = Gregorian.calendar.dateComponents([.year, .month], from: self)
        return Gregorian.calendar.date(from: components)!
    }
    
    func endOfMonth() -> Date {
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.second = -1
        return Gregorian.calendar.date(byAdding: comps2, to: startOfMonth(), wrappingComponents: false)!
    }
    
    func startOfYear() -> Date {
        let components = Gregorian.calendar.dateComponents([.year], from: self)
        return Gregorian.calendar.date(from: components)!
    }
    
    func endOfYear() -> Date {
        var comps2 = DateComponents()
        comps2.year = 1
        comps2.second = -1
        return Gregorian.calendar.date(byAdding: comps2, to: startOfYear(), wrappingComponents: false)!
    }
    
    func currentTimeZoneDate() -> String {
        let dtf = DateFormatter()
        dtf.timeZone = TimeZone.current
        dtf.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dtf.string(from: self)
    }
    
    func getYear() -> Int {
        let components = Gregorian.calendar.dateComponents([.year], from: self)
        return  components.year!
    }
    
    func getMonthOfYear() -> Int {
        let components = Gregorian.calendar.dateComponents([.month], from: self)
        return  components.month!
    }
    
    func getWeekOfYear() -> Int {
        let components = Gregorian.calendar.dateComponents([.weekOfYear], from: self)
        return  components.weekOfYear!
    }
    
    func getDayOfYear() -> Int {
        return Gregorian.calendar.ordinality(of: .day, in: .year, for: self)!
    }
    
    func getDayHourMinuteValue() -> Double {
        let hour = Calendar.current.component(.hour, from: self)
        let minute = Calendar.current.component(.hour, from: self)
        
        return Double(hour) + (Double(minute) / 60.0)
    }
}

internal extension DateComponents {
    mutating func to12pm() {
        hour = 12
        minute = 0
        second = 0
    }
}

protocol KTUINavigatedControlDelegate {
    func navigatedCalenderUpdateEvent(selectedRange: RangeTimeInteval, isTouchEvent: Bool)
}

class KTUINavigatedControl: UIView {

    var delegate : KTUINavigatedControlDelegate?
    
    var btnLeft : UIButton?
    var lblCurrent : UILabel?
    var btnRight : UIButton?
    
    var viewWidth : CGFloat?
    var viewAvailableWidth : CGFloat?
    var viewHeight : CGFloat?
    let viewWidthRatio : CGFloat = 0.7
    
    var btnLeftX : CGFloat?
    var btnLeftY : CGFloat?
    var btnLeftWidth : CGFloat?
    var btnLeftHeight : CGFloat?
    var btnLeftWidthRatio : CGFloat = 0.15
    
    var lblCurrentX : CGFloat?
    var lblCurrentY : CGFloat?
    var lblCurrentWidth : CGFloat?
    var lblCurrentHeight : CGFloat?
    var lblCurrentWidthRatio : CGFloat = 0.7
    
    var btnRightX :CGFloat?
    var btnRightY : CGFloat?
    var btnRightWidth :CGFloat?
    var btnRightHeight : CGFloat?
    var btnRightWidthRatio : CGFloat = 0.15
    
    var allControlHeightRatio : CGFloat = 0.8
    
    let generatLabelFont = UIFont.init(name: "Arial", size: 15)
    let textColor = UIColor.gray
    
    var currentSelectionDate : Date?
    var currentDateType : dateType?
    var minDateSupported : Date?
    var maxDateSupported : Date?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    func setupControl(selectedDateType : dateType, currentDate : Date, minDate: Date, maxDate: Date) {
        minDateSupported = minDate
        maxDateSupported = maxDate
        currentDateType = selectedDateType
        currentSelectionDate = currentDate
        
        let subViews = self.subviews
        for view in subViews {
            view.removeFromSuperview()
        }
        
        viewWidth = self.frame.size.width
        viewHeight = self.frame.size.height
        
        viewAvailableWidth = viewWidth! * viewWidthRatio
        
        btnLeftWidth = viewAvailableWidth! * btnLeftWidthRatio
        lblCurrentWidth = viewAvailableWidth! * lblCurrentWidthRatio
        btnRightWidth = viewAvailableWidth! * btnRightWidthRatio
        
        btnLeftHeight = viewHeight! * allControlHeightRatio
        lblCurrentHeight = viewHeight! * allControlHeightRatio
        btnRightHeight = viewHeight! * allControlHeightRatio
        
        btnLeftX = (viewWidth! - viewAvailableWidth!) / 2.0
        btnLeftY = (viewHeight! * (1.0 - allControlHeightRatio)) / 2.0
        
        lblCurrentX = btnLeftX! + btnLeftWidth!
        lblCurrentY = btnLeftY
        
        btnRightX = lblCurrentX! + lblCurrentWidth!
        btnRightY = btnLeftY
        
        
        btnLeft = UIButton(type: .system)
        btnLeft?.frame = CGRect(x: btnLeftX!, y: btnLeftY!, width: btnLeftWidth!, height: btnLeftHeight!)
        
        lblCurrent = UILabel(frame: CGRect(x: lblCurrentX!, y: lblCurrentY!, width: lblCurrentWidth!, height: lblCurrentHeight!))
        
        btnRight = UIButton(type: .system)
        btnRight?.frame = CGRect(x: btnRightX!, y: btnRightY!, width: btnRightWidth!, height: btnRightHeight!)
        
        
        btnLeft?.titleLabel?.textAlignment = .center
        btnRight?.titleLabel?.textAlignment = .center
        lblCurrent?.textAlignment = .center
        
        setupControls()
    }
    
    func setupControls(){
        
        btnLeft?.setTitle("<", for: UIControlState.normal)
        btnLeft?.titleLabel?.font = generatLabelFont
        
        lblCurrent?.font = generatLabelFont
        lblCurrent?.textColor = textColor
        
        btnRight?.setTitle(">", for: UIControlState.normal)
        btnRight?.titleLabel?.font = generatLabelFont
        
        btnLeft?.addTarget(self, action: #selector(btnLeft_TouchUpInside), for: .touchUpInside)
        btnRight?.addTarget(self, action: #selector(btnRight_TouchUpInside), for: .touchUpInside)
        
        self.addSubview(btnLeft!)
        self.addSubview(lblCurrent!)
        self.addSubview(btnRight!)
        
        performNavigation(changeValue: 0)
    }
    
    func btnLeft_TouchUpInside(sender : UIButton) {
        performNavigation(changeValue: -1)
    }
    
    func btnRight_TouchUpInside(sender : UIButton) {
        performNavigation(changeValue: +1)
    }
    
    func performNavigation(changeValue: Int) {
        
        let objRangeTimeInterval : RangeTimeInteval!
        
        switch currentDateType! {
        case .day:
            let tempCurrentSelectionDate = NSCalendar.current.date(byAdding: .day, value: changeValue, to: currentSelectionDate!)
            if tempCurrentSelectionDate?.isBetweeen(date: minDateSupported!, andDate: maxDateSupported!) == false {
                return
            }
            currentSelectionDate = tempCurrentSelectionDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE dd-MMM-yy"
            lblCurrent?.text = dateFormatter.string(from: currentSelectionDate!)
            
            objRangeTimeInterval = RangeTimeInteval(startTimeInteval: currentSelectionDate!.startOfDay.timeIntervalSince1970, endTimeInterval: currentSelectionDate!.endOfDay.timeIntervalSince1970)
            
        case .week:
            let tempCurrentSelectionDate = NSCalendar.current.date(byAdding: .weekOfYear, value: changeValue, to: currentSelectionDate!)
            if tempCurrentSelectionDate?.isBetweeen(date: minDateSupported!, andDate: maxDateSupported!) == false {
                return
            }
            currentSelectionDate = tempCurrentSelectionDate
            let calendar = Calendar.current
            
            var weekOfYear = 52
            
            if currentSelectionDate!.startOfWeek(weekday: 2).getYear() ==  Date().getYear() {
                weekOfYear = calendar.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0))
            } else {
                weekOfYear = calendar.component(.weekOfYear, from: currentSelectionDate!.startOfWeek(weekday: 2).endOfYear())
            }
            
            let selectedWeek = calendar.component(.weekOfYear, from: currentSelectionDate!)
            lblCurrent?.text = "Week # \(selectedWeek)"
            
            objRangeTimeInterval = RangeTimeInteval(startTimeInteval: currentSelectionDate!.startOfWeek(weekday: 2).timeIntervalSince1970, endTimeInterval: currentSelectionDate!.endOfWeek(weekday: 2).timeIntervalSince1970)
            
        case .month:
            let tempCurrentSelectionDate = NSCalendar.current.date(byAdding: .month, value: changeValue, to: currentSelectionDate!)
            if tempCurrentSelectionDate?.isBetweeen(date: minDateSupported!, andDate: maxDateSupported!) == false {
                return
            }
            currentSelectionDate = tempCurrentSelectionDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM-yy"
            lblCurrent?.text = dateFormatter.string(from: currentSelectionDate!)
            
            objRangeTimeInterval = RangeTimeInteval(startTimeInteval: currentSelectionDate!.startOfMonth().timeIntervalSince1970, endTimeInterval: currentSelectionDate!.endOfMonth().timeIntervalSince1970)
            
        case .year:
            let tempCurrentSelectionDate = NSCalendar.current.date(byAdding: .year, value: changeValue, to: currentSelectionDate!)
            if tempCurrentSelectionDate?.isBetweeen(date: minDateSupported!, andDate: maxDateSupported!) == false {
                return
            }
            currentSelectionDate = tempCurrentSelectionDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            lblCurrent?.text = dateFormatter.string(from: currentSelectionDate!)
            
            objRangeTimeInterval = RangeTimeInteval(startTimeInteval: currentSelectionDate!.startOfYear().timeIntervalSince1970, endTimeInterval: currentSelectionDate!.endOfYear().timeIntervalSince1970)
        }
        
        delegate?.navigatedCalenderUpdateEvent(selectedRange: objRangeTimeInterval, isTouchEvent: changeValue == 0 ? false : true)
    }
}
