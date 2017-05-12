//
//  ViewController.swift
//  KTNavigatedCalendar
//
//  Created by Kartik Patel on 5/6/17.
//  Copyright © 2017 KTPatel. All rights reserved.
//

import UIKit


class ViewController: UIViewController, KTUINavigatedControlDelegate {
   
    @IBOutlet weak var scDuration: UISegmentedControl!
    
    @IBOutlet weak var viewNavigatedCalendar: KTUINavigatedControl!
    
    @IBOutlet weak var lblStartTimeInterval: UILabel!
    @IBOutlet weak var lblStartDateTime: UILabel!
    
    @IBOutlet weak var lblEndTimeInterval: UILabel!
    @IBOutlet weak var lblEndDateTime: UILabel!
    
    var selectedDuration : dateType = .day
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        viewNavigatedCalendar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupNavigatedCalenderValues(selectedDateType: selectedDuration)
    }
    
    @IBAction func scDuration_valueChanged(_ sender: Any) {
        
        switch scDuration.selectedSegmentIndex {
        case 0: //day
            selectedDuration = .day
        case 1: //week
            selectedDuration = .week
        case 2: //month
            selectedDuration = .month
        case 3: //year
            selectedDuration = .year
        default: break
        }
        
        setupNavigatedCalenderValues(selectedDateType: selectedDuration)
    }
    
    // Mark: NavigatedCalender view setup
    func setupNavigatedCalenderValues(selectedDateType : dateType) {
        let minDate = NSCalendar.current.date(byAdding: .month, value: -14, to: Date())
        let maxDate = NSCalendar.current.date(byAdding: .month, value: 14, to: Date())
        viewNavigatedCalendar.setupControl(selectedDateType: selectedDateType, currentDate: Date(), minDate: minDate!, maxDate: maxDate!)
    }
    
    // Mark: KTUINavigatedControlDelegate
    func navigatedCalenderUpdateEvent(selectedRange: RangeTimeInteval, isTouchEvent: Bool) {
        print("Start time: \(Date.init(timeIntervalSince1970: selectedRange.start!)), End time: \(Date.init(timeIntervalSince1970: selectedRange.end!))")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yy HH:mm:ss"
        
        lblStartTimeInterval.text = "\(selectedRange.start!)"
        let startDate = Date.init(timeIntervalSince1970: selectedRange.start!)
        lblStartDateTime.text = dateFormatter.string(from: startDate)
        
        lblEndTimeInterval.text = "\(selectedRange.end!)"
        let endDate = Date.init(timeIntervalSince1970: selectedRange.end!)
        lblEndDateTime.text = dateFormatter.string(from: endDate)
    }
}
