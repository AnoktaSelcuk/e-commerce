//
//  EditProfileViewController.swift
//  internProject
//
//  Created by Alperen Selçuk on 10.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import UIKit
import JGProgressHUD

class EditProfileViewController: UIViewController {
    
    //MARK: IBOulets
    
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var surnameTextField: UITextField!
    
    @IBOutlet weak var adressTextField: UITextField!
    
    //MARK: Vars
    let hud = JGProgressHUD(style: .dark)
    
    
    //MARK: view Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserInfo()
        
    }
    
    //MARK: IBActions

    @IBAction func saveBarButtonPressed(_ sender: Any) {
        
        dissmissKeyboard()

        if textFieldHaveText() {
            
            let withValues = [kFIRSTNAME : nameTextField.text!, kLASTTNAME : surnameTextField.text!, kFULLTNAME : (nameTextField.text! + " " + surnameTextField.text!), kFULLADDRESS : adressTextField.text!]
            
  
            updateCurrentUserInFirestore(withvalues: withValues) { (error) in
                
                if error == nil {
                    
                    self.hud.textLabel.text = "Updated"
                    self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                    
                } else {
                    print("error: ", error!.localizedDescription) //debug icin
                    self.hud.textLabel.text = error!.localizedDescription
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                    
                }
            }
            
        } else {
            hud.textLabel.text = "All fields are required!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
        
        
    }
    @IBAction func logOutButtonPressed(_ sender: Any) {
        logOutUser()
    }
    
    //MARK: updateui segue ile buraya gelirken..
    private func loadUserInfo() {
            
        if MUser.currentUser() != nil {
            let currentUser = MUser.currentUser()!
            
            nameTextField.text = currentUser.firstName
            surnameTextField.text = currentUser.lastName
            adressTextField.text = currentUser.fullAdress
        }
    }
    
    //MARK: Helper
    
    private func dissmissKeyboard() {
        self.view.endEditing(false)
    }
    
    private func textFieldHaveText() -> Bool {
        
        return (nameTextField.text != "" && surnameTextField.text != "" && adressTextField.text != "")
    }
    
    private func logOutUser() {
        MUser.logOutCurrentUser { (error) in
            
            if error == nil {
                print("logged out!")
                self.navigationController?.popViewController(animated: true) 
            } else {
                print("error login out", error!.localizedDescription)
            }
        }
    }
}
