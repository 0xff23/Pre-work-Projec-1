//
//  ViewController.swift
//  Tip Calculator
//
//  Created by Kirill on 7/29/17.
//  Copyright © 2017 KG. All rights reserved.
//

import UIKit
import Foundation


extension String {
    
    var length: Int {
        return self.characters.count
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return self[Range(start ..< end)]
    }
    
}

class ViewController: UIViewController, SettingsViewControllerDelegate {
    
    //Outlets for label and buttons
    @IBOutlet var NumberPad: UIView!
    
    @IBOutlet weak var BillAmountLabel: UILabel!
    @IBOutlet weak var BillLabel: UIButton!
    @IBOutlet weak var SettingsLabel: UIButton!
    @IBOutlet weak var TipPersentageLabel: UILabel!
    @IBOutlet weak var TipPersentsLabel: UILabel!
    @IBOutlet weak var TipAmountLabel: UILabel!
    @IBOutlet weak var TipLabel: UILabel!
    @IBOutlet weak var NumberOfPeopleLabel: UILabel!
    @IBOutlet weak var NumberLabel: UILabel!
    @IBOutlet weak var BillPerPersoneLabel: UILabel!
    @IBOutlet weak var EachPersoneLabel: UILabel!
    @IBOutlet weak var TotalBillLabel: UILabel!
    @IBOutlet weak var TotalAmountLabel: UILabel!
    @IBOutlet weak var CurencyLabel: UILabel!
    
    //Varibles
    var tipPersents = 0.15
    var numberOfPeople = 1.0
    var eachPersonPay = 0.0
    var tipAmount = 0.0
    var currency = "$"
    var totalBill = 0.0
    var myBillString = "0"
    var myBillDouble = 0.0
    var isBillWholeNumber = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Setting up main screen
        TipPersentageLabel.adjustsFontSizeToFitWidth = true
        NumberOfPeopleLabel.adjustsFontSizeToFitWidth = true
        EachPersoneLabel.adjustsFontSizeToFitWidth = true
        
        BillLabel.contentHorizontalAlignment = .right
        CurencyLabel.isHidden = true
        BillAmountLabel.adjustsFontSizeToFitWidth = true
        BillLabel.titleLabel?.adjustsFontSizeToFitWidth = true

        //Setting values for labels when opening app
        settingLabels()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Preparing for the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsvc" {
            let destViewController = segue.destination as!  SettingsViewControler
                destViewController.delegate = self
                destViewController.myCurentcy = currency
                destViewController.defaultAmmount = tipPersents
                destViewController.isRoundBill = isBillWholeNumber
        }
    }
    
    //Setting up main screen after saving settings, conferming the protocol
    func SettingsViewControllerFinishedSetting(_ controller: SettingsViewControler, Curentcy: String, isRound: Bool, defaultTipAmount: Double) {
        currency = Curentcy
        isBillWholeNumber = isRound
        tipPersents = defaultTipAmount
        
        if myBillString == "0"{
            settingLabels()
        } else {
            if isBillWholeNumber{
                BillLabel.setTitle(String(format: "%.0f", Double( myBillString)!) + currency, for: .normal)
            } else {
                BillLabel.setTitle(String(format: "%.2f", Double( myBillString)!) + currency, for: .normal)
            }
            settingLabels()
        }
        
        UserDefaults.standard.setValue(currency, forKey: "MyValue")
        UserDefaults.standard.setValue(isBillWholeNumber, forKey: "Round")
        UserDefaults.standard.setValue(tipPersents, forKey: "DefaultTip")
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let x = UserDefaults.standard.object(forKey: "Round"){
            isBillWholeNumber = x as! Bool
        }
        
        if let x = UserDefaults.standard.object(forKey: "MyValue"){
            currency = x as! String
            settingLabels()
        }
        
        if let x = UserDefaults.standard.object(forKey: "DefaultTip"){
            tipPersents = x as! Double
            settingLabels()
        }
        
    }

    //Setting up sizee and aligment for number pad
    @IBAction func ShowNumberPad(_ sender: Any) {
        SettingsLabel.isHidden = true
        CurencyLabel.isHidden = false
        BillLabel.contentHorizontalAlignment = .right
        
        NumberPad.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(NumberPad)
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint(item: NumberPad, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: view.frame.width).isActive = true
        NumberPad.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0).isActive = true
        NumberPad.topAnchor.constraint(equalTo: margins.topAnchor, constant: 143).isActive = true
        
        BillLabel.setTitle("0", for: .normal)

    }
    
    //Closing number pad
    @IBAction func CloseNumberPad(_ sender: Any) {
        self.NumberPad.removeFromSuperview()
        BillLabel.titleLabel?.adjustsFontSizeToFitWidth = false
        SettingsLabel.isHidden = false
        CurencyLabel.isHidden = true
        BillLabel.contentHorizontalAlignment = .center
        myBillString = BillLabel.currentTitle!
        
        if isBillWholeNumber{
            BillLabel.setTitle(String(format: "%.0f", Double( myBillString)!) + currency, for: .normal)
        } else {
            BillLabel.setTitle(String(format: "%.2f", Double( myBillString)!) + currency, for: .normal)
        }
        
        calculating()
        settingLabels()
        
    }
    
    //Dialing bill ammount
    @IBAction func Numbers(_ sender: UIButton) {
       var timeToStop = false
       
        
       
        
        //Cheking if number has two numbers after dot
        if BillLabel.currentTitle!.characters.count > 2 && BillLabel.currentTitle![BillLabel.currentTitle!.characters.count - 3] == "." {
            
            timeToStop = true
        }
        
        //Setting numbers
        if timeToStop != true {

            if BillLabel.currentTitle == "0" && sender.tag != 12 && sender.tag != 11 && sender.tag != 10 {
                BillLabel.setTitle(String(sender.tag), for: .normal)
            } else if BillLabel.currentTitle != "0" && sender.tag != 11 && sender.tag != 12 || (sender.tag != 12 && sender.tag != 11 && sender.tag != 10) {
                if sender.tag == 10 {
                    BillLabel.setTitle(BillLabel.currentTitle! + "0", for: .normal)
                } else {
                    BillLabel.setTitle(BillLabel.currentTitle! + String(sender.tag), for: .normal)
                }
            }
        
        //Setting dot fot the numebr
            if sender.tag == 11 && (BillLabel.currentTitle!.range(of: ".") == nil) && isBillWholeNumber == false {
                BillLabel.setTitle(BillLabel.currentTitle! + ".", for: .normal)
            }
        }
        
        //Deleting numbers
        if sender.tag == 12 && BillLabel.currentTitle! != "0" {
           var labelNumber = BillLabel.currentTitle!
            if labelNumber.characters.count == 1 {
                BillLabel.setTitle("0", for: .normal)
            } else {
                labelNumber.remove(at: labelNumber.index(before: labelNumber.endIndex))
                BillLabel.setTitle(labelNumber, for: .normal)
            }
        }
    }
    
    //Tip persents increase
    @IBAction func TipUp(_ sender: Any) {
        tipPersents = tipPersents + 0.01
        calculating()
        settingLabels()
    }
    
    //Tip persents decrease
    @IBAction func TipDown(_ sender: Any) {
        if tipPersents > 0.01  {
            tipPersents = tipPersents - 0.01
            calculating()
            settingLabels()
            
        }
        
    }
    
    //Increase number of peope
    @IBAction func PeopleUP(_ sender: Any) {
        numberOfPeople += 1
        calculating()
        settingLabels()
    }
    
    //Dicrease number of people
    @IBAction func PeopleDown(_ sender: Any) {
        if numberOfPeople != 1 {
            numberOfPeople -= 1
            calculating()
            settingLabels()
        }
    }
    
    //Cleaning everything
    @IBAction func ClearEverything(_ sender: Any) {
        eachPersonPay = 0.0
        tipAmount = 0.0
        currency = "$"
        totalBill = 0.0
        myBillString = "0"
        myBillDouble = 0.0
        settingLabels()
        BillLabel.setTitle("Please enter your bill", for: .normal)
        BillLabel.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    //Pay btn
    @IBAction func PayTheBill(_ sender: Any) {
        
    }
    
    
    //Settings labels
    func settingLabels() {
        
        TipPersentsLabel.text = String(format: "%.0f", tipPersents * 100) + "%"
        NumberLabel.text = String(format: "%.0f", numberOfPeople)
        
        if isBillWholeNumber {
            TipAmountLabel.text = String(format: "%.0f", tipAmount) + currency
            BillPerPersoneLabel.text = String(format: "%.0f",eachPersonPay) + currency
            TotalAmountLabel.text = String(format: "%.0f", totalBill) + currency
            TipAmountLabel.textAlignment = .center
            BillPerPersoneLabel.textAlignment = .center
        } else {
            TipAmountLabel.text = String(format: "%.2f", tipAmount) + currency
            BillPerPersoneLabel.text = String(format: "%.2f",eachPersonPay) + currency
            TotalAmountLabel.text = String(format: "%.2f", totalBill) + currency
            TipAmountLabel.textAlignment = .center
            BillPerPersoneLabel.textAlignment = .center
        }
        
        CurencyLabel.text = currency
    }
    
    //Calculating numbers for labels
    func calculating ( ){
        myBillDouble = Double(myBillString)!
        tipAmount = myBillDouble * tipPersents
        totalBill = tipAmount + myBillDouble
        eachPersonPay = totalBill / numberOfPeople
    }
    
}

