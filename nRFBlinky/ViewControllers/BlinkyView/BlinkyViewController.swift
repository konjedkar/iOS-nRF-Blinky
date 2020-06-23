//
//  BlinkyViewController.swift
//  nRFBlinky
//
//  Created by Mostafa Berg on 01/12/2017.
//  Copyright © 2017 Nordic Semiconductor ASA. All rights reserved.
//

import UIKit
import CoreBluetooth
import UserNotifications


class BlinkyViewController: UITableViewController, BlinkyDelegate {
    
    // MARK: - Outlets and Actions
    
    @IBOutlet weak var ledStateLabel: UILabel!
    @IBOutlet weak var ledToggleSwitch: UISwitch!
    @IBOutlet weak var buttonStateLabel: UILabel!
    @IBOutlet weak var textLastPostureTime: UILabel!
    @IBOutlet weak var textWarning: UILabel! 
    @IBOutlet weak var textSensorState: UILabel!
    @IBOutlet weak var percentProgressBar: UIProgressView!
    @IBOutlet weak var imageSitting: UIImageView!
    @IBOutlet weak var imageVacant: UIImageView!
    @IBOutlet weak var imageImproper: UIImageView!
    
    @IBAction func ledToggleSwitchDidChange(_ sender: Any) {
        handleSwitchValueChange(newValue: ledToggleSwitch.isOn)
    }

    // MARK: - Properties

    private var hapticGenerator: NSObject? // Only available on iOS 10 and above
    private var blinkyPeripheral: BlinkyPeripheral!
    private var centralManager: CBCentralManager!
    
    // MARK: - Public API
    
    public func setPeripheral(_ peripheral: BlinkyPeripheral) {
        blinkyPeripheral = peripheral
        title = peripheral.advertisedName
        peripheral.delegate = self
    }
    
    // MARK: - UIViewController
    
   // private var content:UNMutableNotificationContent
   // private var center:UNUserNotificationCenter
    

    
    override func viewDidLoad() {
        super.viewDidLoad()


           // setAlarmNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !blinkyPeripheral.isConnected else {
            // View is coming back from a swipe, everything is already setup
            return
        }
        prepareHaptics()
        blinkyPeripheral.connect()
        self.imageImproper.alpha = 0
        self.imageSitting.alpha = 0
        self.imageVacant.alpha = 1
        self.percentProgressBar.alpha = 0
    }

    override func viewDidDisappear(_ animated: Bool) {
        blinkyPeripheral.disconnect()
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Implementation
    
    private func handleSwitchValueChange(newValue isOn: Bool){
        if isOn {
            blinkyPeripheral.turnOnLED()
            ledStateLabel.text = "ON".localized
        } else {
            blinkyPeripheral.turnOffLED()
            ledStateLabel.text = "OFF".localized
        }
    }

    /// This will run on iOS 10 or above
    /// and will generate a tap feedback when the button is tapped on the Dev kit.
    private func prepareHaptics() {
        if #available(iOS 10.0, *) {
            hapticGenerator = UIImpactFeedbackGenerator(style: .heavy)
            (hapticGenerator as? UIImpactFeedbackGenerator)?.prepare()
        }
    }
    
    /// Generates a tap feedback on iOS 10 or above.
    private func buttonTapHapticFeedback() {
        if #available(iOS 10.0, *) {
            (hapticGenerator as? UIImpactFeedbackGenerator)?.impactOccurred()
        }
    }
    
    // MARK: - Blinky Delegate
    
    func blinkyDidConnect(ledSupported: Bool, buttonSupported: Bool) {
        DispatchQueue.main.async {
            self.ledToggleSwitch.isEnabled = ledSupported
            
            if buttonSupported {
                self.buttonStateLabel.text = "Reading...".localized
            }
            if ledSupported {
                self.ledStateLabel.text    = "Reading...".localized
            }
        }
        // Not supoprted device?
        if !ledSupported && !buttonSupported {
            blinkyPeripheral.disconnect()
        }
    }
    
    func blinkyDidDisconnect() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.barTintColor = UIColor.nordicRed
            self.ledToggleSwitch.onTintColor = UIColor.nordicRed
            self.ledToggleSwitch.isEnabled = false
        }
    }
    
    func ledStateChanged(isOn: Bool) {
        DispatchQueue.main.async {
            if isOn {
                self.ledStateLabel.text = "ON".localized
                self.ledToggleSwitch.setOn(true, animated: true)
            } else {
                self.ledStateLabel.text = "OFF".localized
                self.ledToggleSwitch.setOn(false, animated: true)
            }
        }
    }
    
    func buttonStateChanged(isPressed: Bool) {
        DispatchQueue.main.async {
        /*    if isPressed {
                self.buttonStateLabel.text = "PRESSED".localized
                //self.butt
            } else {
                self.buttonStateLabel.text = "VACANT".localized
            }
            self.buttonTapHapticFeedback()*/
        }
    }
     static var data_rec_chair_state : UInt8 = 0
     static var data_rec_alarmed : Bool = false
     static var data_rec_pressed : Bool = false
     static var setImageResourceImproper : Bool = false
     
    static var savedSeatHour : Int32 = 0
    static var savedSeatMin : Int32 = 2
    static var savedBreakHour : Int32 = 0
    static var savedBreakMin : Int32 = 1
    
    
    
     
     
     let STATE_SEATED_IMPROPER = 0x03
     let STATE_SEATED = 0x01
     let STATE_NOT_SEATED = 0x00
    
     
     let CHAIR_IDLE = 0
     let CHAIR_SEATED = 1
     let CHAIR_BREAK = 2
     
    
    func getLastPostureTime(pressed : Int8 , last_posture_sec: NSInteger, last_posture_min: NSInteger, last_posture_hour: NSInteger , long_seat_alert : NSInteger ) {
        DispatchQueue.main.async {
            if last_posture_sec < 60 {
                self.textLastPostureTime.text = String(format: "%02d", last_posture_hour) + ":"+String(format: "%02d", last_posture_min) + ":" + String(format: "%02d", last_posture_sec) //"\(last_posture_hour):\(last_posture_min):\(last_posture_sec)".localized
                //self.butt
            } else {
                self.textLastPostureTime.text = String(format: "%02d", last_posture_hour) + ":"+String(format: "%02d", last_posture_min)
            }
            
            
            
            //getAlarmPercentage() in android
             var alarmPercentage:Int32
             var alarmMinTotal:Int32
             alarmPercentage = Int32(last_posture_hour) * 3600
             alarmPercentage += Int32(last_posture_min) * 60
            if(last_posture_sec<60) {
                alarmPercentage += Int32(last_posture_sec)        //alarmPercentage is in second
            }
             alarmPercentage *= 10
             alarmPercentage /= 6       //alarmMinTotal is in min. so we must /60 for min and * 100 for percent. (= *10 /6)

            if pressed != self.STATE_NOT_SEATED {            //if seated, use SeatAlarm as reference
                 alarmMinTotal = BlinkyViewController.savedSeatHour * 60;
                 alarmMinTotal += BlinkyViewController.savedSeatMin;
             }
             else{
                 alarmMinTotal = BlinkyViewController.savedBreakHour * 60;    //if not seated, use Break Time as reference
                 alarmMinTotal += BlinkyViewController.savedBreakMin;
             }
            if(alarmMinTotal>0) {
                alarmPercentage /= alarmMinTotal
            }
             //alarmPercentage++;
            if(alarmPercentage>100){
                alarmPercentage=100
            }
            
            self.percentProgressBar.progress = Float(alarmPercentage) / 100
            
            if pressed == self.STATE_NOT_SEATED { //!BlinkyViewController.data_rec_pressed {
                if alarmPercentage>99 {
                    self.percentProgressBar.alpha = 0
                }
            }
            else {
                    if BlinkyViewController.data_rec_alarmed {
                        self.percentProgressBar.progress = 1
                    }
            }
           /// end of getAlarmPercentage
            
            

        }
    }
    
    let REAR_SENSOR_BIT : UInt8 = 0x80
    let FRONT_SENSOR_BIT : UInt8 = 0x40
    
    func getSensorsState(sensorState:UInt8){
        var textSensor : String = ""
        if (sensorState & REAR_SENSOR_BIT) > 0 {
            textSensor += "R"
        }
        else {
            textSensor += " "
        }

        textSensor += "|"

        if((sensorState & FRONT_SENSOR_BIT) > 0){
            textSensor += "F"
        }
        else {
            textSensor += " "
        }

        if(sensorState==0) {
            textSensor = ""
        }
        self.textSensorState.text = textSensor
    }
    

    func getChairState(chairState:UInt8){
        if chairState == CHAIR_SEATED{
            self.buttonStateLabel.text = "Sitting"
        }
            else if chairState == CHAIR_IDLE{
                self.buttonStateLabel.text = "Idle"
        }
        else{
              self.buttonStateLabel.text = "Break"
        }
    }
    
    func getButtonState(pressed: UInt8){
        if pressed == STATE_SEATED_IMPROPER{
            BlinkyViewController.setImageResourceImproper = true
            // self.textSensorState.text = "*"
            BlinkyViewController.data_rec_chair_state = pressed
        }
        else if pressed == STATE_SEATED {
            BlinkyViewController.setImageResourceImproper = false
            //self.textSensorState.text = "**"
            BlinkyViewController.data_rec_chair_state = pressed
        }
        else {
            //self.textSensorState.text = ""
        }
        
        if pressed != STATE_NOT_SEATED {
            if !BlinkyViewController.data_rec_pressed {
                self.imageVacant.alpha = 0
                if BlinkyViewController.setImageResourceImproper {
                     self.imageSitting.alpha = 0
                    self.imageImproper.alpha = 1
                }
                else {
                    self.imageSitting.alpha = 1
                    self.imageImproper.alpha = 0
                }
            }

            
            self.percentProgressBar.alpha = 1
            BlinkyViewController.data_rec_pressed = true
        }
        else {
                if BlinkyViewController.data_rec_pressed {
                    self.imageVacant.alpha = 1
                    self.imageSitting.alpha = 0
                    self.imageImproper.alpha = 0
                }
            
                if !BlinkyViewController.data_rec_alarmed {
                     self.percentProgressBar.alpha = 0
                }
                BlinkyViewController.data_rec_pressed = false
            
        }
        
    }
    
    func getSeatAlarm ( seatAlarm : Bool) {
        DispatchQueue.main.async {
            

            
            if seatAlarm {
                if !BlinkyViewController.data_rec_pressed{
                    BlinkyViewController.data_rec_alarmed = false
                    self.textLastPostureTime.text = "Ready"
                    self.textWarning.text = "Please sit down on your Smart Chair"
                    self.textWarning.textColor = UIColor.colorBorder
                    self.textLastPostureTime.textColor = UIColor.colorBorder
                }
               else {
                    self.textLastPostureTime.textColor = UIColor.colorTimeNormal
                    if BlinkyViewController.data_rec_chair_state != 3 {
                        self.textWarning.text = "Just Relax! We are measuring your sit time"
                        self.textWarning.textColor = UIColor.colorTimeNormal
                    }
                    else{
                        self.textWarning.text = "Improper Sitting Posture"
                        self.textWarning.textColor = UIColor.colorAlarm
                    }
                
                }
            
            }
            else {
                 BlinkyViewController.data_rec_alarmed = true
                 if !BlinkyViewController.data_rec_pressed{
                    self.textLastPostureTime.textColor = UIColor.colorTimeNormal
                    self.textWarning.text = "Continue with your brief break"
                    self.textWarning.textColor = UIColor.colorTimeNormal
                 }
                else {
                    self.textLastPostureTime.textColor = UIColor.colorAlarm
                    self.textWarning.text = "Time to get up and stretch"
                    self.textWarning.textColor = UIColor.colorAlarm
                 }
            }

            
        
         }
        
    }
    
    
}
