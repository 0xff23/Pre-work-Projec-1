//
//  SettingsViewController.swift
//  Tip Calculator
//
//  Created by Kirill on 7/29/17.
//  Copyright © 2017 KG. All rights reserved.
//

import Foundation
import UIKit


protocol SettingsViewControllerDelegate: class {
    func SettingsViewControllerFinishedSetting(_ controller: SettingsViewControler, Curentcy: String, isRound: Bool, defaultTipAmount: Double)
}

class SettingsViewControler: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //Variables
    weak var delegate: SettingsViewControllerDelegate?
    var pickerDataSource = ["$", "€", "¥", "£", "Fr", "¥", "kr", "₩", "₺", "₽", "₹", "R$",  "R"];
    var myCurentcy = "$"
    var isRoundBill = false
    var defaultAmmount = 0.18
    
    //Outlets
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var ClosePickerViewButton: UIButton!
    @IBOutlet weak var CloseSettingsScreenButton: UIButton!
    @IBOutlet weak var CurentcyLabel: UILabel!
    @IBOutlet weak var ChooseCurentcyButton: UIButton!
    @IBOutlet weak var BoxButton: UIButton!
    @IBOutlet weak var defaultTipPicker: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        
        //Load settings
        let defaultSettingsLoad = UserDefaults.standard
        
        if let isRound = defaultSettingsLoad.bool(forKey: "isRoundEnable") as? Bool {
             isRoundBill = isRound
        }

        if let defaultTipsSet = defaultSettingsLoad.double(forKey: "defaultTips") as? Double{
            defaultAmmount = defaultTipsSet
        }
        
        if let myCurentcySelectedSet = defaultSettingsLoad.string(forKey: "myCurentcySelected") {
            myCurentcy = myCurentcySelectedSet
        }
        
        ChooseCurentcyButton.contentHorizontalAlignment = .left
        
        pickerView.isHidden = true
        ClosePickerViewButton.isHidden = true
        
        CurentcyLabel.text = myCurentcy
        
        if isRoundBill {
            BoxButton.setImage(#imageLiteral(resourceName: "ChekedBox"), for: .normal)
        } else {
            BoxButton.setImage(#imageLiteral(resourceName: "EmptyBox"), for: .normal)
        }
    }
    
    @IBAction func defaultValueChange(sender:UISegmentedControl) {
        switch defaultTipPicker.selectedSegmentIndex {
        case 0:
            defaultAmmount = 0.18
        case 1:
            defaultAmmount = 0.20
        case 2:
            defaultAmmount = 0.25
        default:
            break;
        }
    
    }
    
    //Numbers of compnets of pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Numbers of rows in pickerView
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    //Titles for rows in pickerView
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    //Setting up selected currency
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        CurentcyLabel.text = pickerDataSource[row]
        myCurentcy = pickerDataSource[row]
    }
    
    //Making text white in pickerView
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: pickerDataSource[row], attributes: [NSForegroundColorAttributeName : UIColor.white])
        return attributedString
    }
    
    //Check and uncheck Rounding the bill
    @IBAction func isRoundBill(_ sender: Any) {
        if isRoundBill == false {
            BoxButton.setImage(#imageLiteral(resourceName: "ChekedBox"), for: .normal)
            isRoundBill = true
        } else {
            BoxButton.setImage(#imageLiteral(resourceName: "EmptyBox"), for: .normal)
            isRoundBill = false
        }
    }
    
    //ShowPicker View
    @IBAction func ShowPickerView(_ sender: Any) {
        pickerView.isHidden = false
        ClosePickerViewButton.isHidden = false
        CloseSettingsScreenButton.isHidden = true
    }
    
    //Closing pickerView
    @IBAction func ClosePickerView(_ sender: Any) {
        pickerView.isHidden = true
        ClosePickerViewButton.isHidden = true
        CloseSettingsScreenButton.isHidden = false
    }
    
    //Save and pass data to the ViewController
    @IBAction func Save(_ sender: Any) {
        delegate?.SettingsViewControllerFinishedSetting(self, Curentcy: myCurentcy, isRound: isRoundBill, defaultTipAmount: defaultAmmount)
        
        //Save settings to default state
        let roundStatus = isRoundBill
        let defaultSelected = defaultTipPicker.selectedSegmentIndex
        let myCurentcySelected = myCurentcy
        
        let defaultSettings = UserDefaults.standard
        defaultSettings.set(roundStatus, forKey: "isRoundEnable")
        defaultSettings.set(defaultSelected, forKey: "defaultTips")
        defaultSettings.set(myCurentcySelected, forKey: "myCurentcySelected")
    }
    
    
    //Dismiss SettingsViewController
    @IBAction func BackToMainScreen(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
}
