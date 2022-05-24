//
//  WelcomeViewController.swift
//  internProject
//
//  Created by Alperen Selçuk on 8.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView

//login ekrani burada!
class WelcomeViewController: UIViewController {

    //MARK: IBOutlet
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resendButtonOutlet: UIButton!
    
    
    //MARK: vars
    
    let hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60.0, height: 60.0), type: .ballPulse, color: #colorLiteral(red: 0.99,  green: 0.49, blue: 0.47, alpha: 1.0), padding: nil)
    }
    
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    //MARK: IBAction
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dissmissView()
    }
    
    @IBAction func logginButtonPressed(_ sender: Any) {
        print("login")
        
        if textFieldsHaveText() {
            
            loginUser()
            
        } else {
            hud.textLabel.text = "All fields are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view) //self viewimizde goster.
            hud.dismiss(afterDelay: 2.0)
        }
        
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        print("register")
        
        if textFieldsHaveText() {
            
            registerUser()
            
            
        } else {
            hud.textLabel.text = "All fields are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view) //self viewimizde goster.
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    @IBAction func forgotPassswordButtonPressed(_ sender: Any) {
        print("forgotpassword")
        
        if emailTextField.text != "" {
            
            resetThePassword()

        } else {
            
            hud.textLabel.text = "Please insert email"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view) //self viewimizde goster.
            hud.dismiss(afterDelay: 2.0)
            
        }
        
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        
        print("resend Email")

        MUser.resendVerificationEmail(email: emailTextField.text!) { (error) in
            print("error resending email: ", error?.localizedDescription)
        }

    }
    

    private func loginUser() {
        
        showLoadingIdicator()
                                                                                                   
        MUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerified) in
            
            if error == nil {
                
                if isEmailVerified {
                    self.dissmissView()
                    print("email is verified")
                } else {
                    
                    self.hud.textLabel.text = "Please Verify Your Email"
                    self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    self.hud.show(in: self.view) //self viewimizde goster.
                    self.hud.dismiss(afterDelay: 2.0)
                    self.resendButtonOutlet.isHidden = false

                }
            } else { 
                print("error logging in user: ", error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view) //self viewimizde goster.
                self.hud.dismiss(afterDelay: 2.0)
                
            }
            self.hideLoadingIdicator()
        }
    }
    
    
    //MARK: Register
    private func registerUser() {
        
        showLoadingIdicator()
        MUser.registerUser(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            
            if error == nil {
                
                self.hud.textLabel.text = "Verification Email Send!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            } else {
                
                print("error: ",error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view) //self viewimizde goster.
                self.hud.dismiss(afterDelay: 2.0)
            }
            
            
            self.hideLoadingIdicator()
            
            
        }
    }
    

    //MARK:login Helper
    
    private func resetThePassword() {
    
        MUser.resentPasswordFor(email: emailTextField.text!) { (error) in
            
            if error != nil {
                
                self.hud.textLabel.text = "Reset password email sent!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
                
            } else {
            
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }
    
    
    private func textFieldsHaveText() -> Bool {
        return (emailTextField.text != "" && passwordTextField.text != "")
    }
    
   
    private func dissmissView() {
        self.dismiss(animated: true, completion: nil) 
    }
    
    //MARK:activity indicator //loading button olaylarina yardimci
    private func showLoadingIdicator() {
     
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator! .startAnimating()
        }
    }
    private func hideLoadingIdicator() {
            
        if activityIndicator != nil {
            
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }
}
