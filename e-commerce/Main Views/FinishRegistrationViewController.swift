//
//  FinishRegistrationViewController.swift
//  internProject
//
//  Created by Alperen Selçuk on 9.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import UIKit
import JGProgressHUD


class FinishRegistrationViewController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var surnameTextField: UITextField!
    
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var doneButtonOutlet: UIButton!
    
    
    
    //MARK: Vars
    var hud = JGProgressHUD(style: .dark)
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

 
        nameTextField.addTarget(self, action: #selector(self.nameTextFieldDidChange(_ :)), for: UIControl.Event.editingChanged)
        surnameTextField.addTarget(self, action: #selector(self.nameTextFieldDidChange(_ :)), for: UIControl.Event.editingChanged)
        addressTextField.addTarget(self, action: #selector(self.nameTextFieldDidChange(_ :)), for: UIControl.Event.editingChanged)

    }
    
    
    //MARK: IBAction
    @IBAction func doneButtonPressed(_ sender: Any) {
        finishOnBoarding()
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func nameTextFieldDidChange(_ textField: UITextField) {
        print("text field did change")
        updateDoneButtonStatus()
    }
    
    
    //MARK: helper(1th: button statusumuzu update yapacak)

    private func updateDoneButtonStatus() {
        if nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "" {
            doneButtonOutlet.backgroundColor = #colorLiteral(red: 1, green: 0.2090041099, blue: 0.1675282027, alpha: 1)
            doneButtonOutlet.isEnabled = true
        } else {
            doneButtonOutlet.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            doneButtonOutlet.isEnabled = false
        }
    }
    
    private func finishOnBoarding() { 
        let withValues = [kFIRSTNAME: nameTextField.text!, kLASTTNAME: surnameTextField.text!, kONBOARD: true, kFULLADDRESS: addressTextField.text!,kFULLTNAME: (nameTextField.text!+" "+surnameTextField.text!)] as [String: Any ]
        
        updateCurrentUserInFirestore(withvalues: withValues) { (error) in
            
            if error == nil {
                self.hud.textLabel.text = "Updating"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)

                self.dismiss(animated: true, completion: nil)
            } else {
                
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)

                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
