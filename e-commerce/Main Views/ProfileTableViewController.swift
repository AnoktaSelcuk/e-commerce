//
//  ProfileTableViewController.swift
//  internProject
//
//  Created by Alperen Selçuk on 9.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import UIKit

//sag uste login butonu koyacagiz bu viewin altina
class ProfileTableViewController: UITableViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var finishRegistrationButtonOutlet: UIButton!
    @IBOutlet weak var purchaseHistoryButtonOutlet: UIButton!
    
    //MARK: vars
    var editBarButtonOutlet: UIBarButtonItem!
    
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkLoginStatus()
        
        checkOnboardingStatus()
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    

// MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    private func checkLoginStatus() {
        
        if MUser.currentUser() == nil {
            
            createRightBarButton(title: "Login")
            
        } else {
            createRightBarButton(title: "Edit")
            
        }
    }
    
    private func checkOnboardingStatus() {
        
        if MUser.currentUser() != nil {
            
            if MUser.currentUser()!.onBoard { //onboard statusune bakiyoruz..
                finishRegistrationButtonOutlet.setTitle("Account is Active", for: .normal)
                finishRegistrationButtonOutlet.isEnabled = false
            } else {
                finishRegistrationButtonOutlet.setTitle("Finish Registiration", for: .normal)
                finishRegistrationButtonOutlet.isEnabled = true
                finishRegistrationButtonOutlet.tintColor = .red             }
            
            purchaseHistoryButtonOutlet.isEnabled = true
            
        } else { //current user yok ise
            finishRegistrationButtonOutlet.setTitle("Logged Out", for: .normal)
            finishRegistrationButtonOutlet.isEnabled = false
            purchaseHistoryButtonOutlet.isEnabled = false
        }
    }

    private func createRightBarButton(title: String) {
                                                                                                
        editBarButtonOutlet = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(rightBarButtonPressed))
                
        self.navigationItem.rightBarButtonItem = editBarButtonOutlet
    }
    
    @objc func rightBarButtonPressed() {

        if editBarButtonOutlet.title == "Login" {
            //show login view
            showLoginView()
            
        } else {
            goToEditProfile()
        }
    }

    private func showLoginView() {
        print("login view loaded")
        let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginView")
        self.present(loginView, animated: true, completion: nil)
    }
    
    private func goToEditProfile() {
        performSegue(withIdentifier: "profileToEditSeg", sender: self)
    }
    
    
}
