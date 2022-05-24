//
//  MUser.swift
//  internProject
//
//  Created by Alperen Selçuk on 8.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import Foundation
import FirebaseAuth


class MUser {
    
    var objectId: String
    var email: String
    var firstName: String
    var lastName: String
    var fullName: String
    var purchasedItemIds: [String]
    
    var fullAdress: String?
    var onBoard: Bool
    
    
    //MARK: Init
    //standart init
    init(_objectId: String, _email: String, _firstName: String, _lastName: String) {
        objectId = _objectId
        email = _email
        firstName = _firstName
        lastName = _lastName
        fullName = _firstName + " " + _lastName
        fullAdress = ""
        onBoard = false //default
        purchasedItemIds = []
    }
    
    init(_dictionary: NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        
        if let mail = _dictionary[kEMAIL] {
            email = mail as! String
        } else {
            email = ""
        }
        
        if let fname = _dictionary[kFIRSTNAME] {
            firstName = fname as! String
        } else {
            firstName = ""
        }
        
        if let lname = _dictionary[kLASTTNAME] {
            lastName = lname as! String
        } else {
            lastName = ""
        }
        
        
        fullName = firstName + " " + lastName
        
        if let fAddress = _dictionary[kFULLADDRESS] {
            fullAdress = fAddress as! String
        } else {
            fullAdress = ""
        }
        
        if let onB = _dictionary[kONBOARD] {
            onBoard = onB as! Bool
        } else {
            onBoard = false
        }
        
        if let purchaseIds = _dictionary[kPURCHASEDITEMIDS] {
            purchasedItemIds = purchaseIds as! [String]
        } else {
            purchasedItemIds = []
        }
    }
    
    //MARK: return current user (login islemleri icin)

    class func currentID() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    
                            
    class func currentUser() -> MUser? {
        
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                
                return MUser.init(_dictionary: dictionary as! NSDictionary)
            }
        }
            
        return nil
    }
    
    class func loginUserWith(email: String, password: String, completition: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
         
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            
            if error == nil {
                
                if authDataResult!.user.isEmailVerified {
                    

                    downloadUserFromFirestore(userId: authDataResult!.user.uid, email: email)
                    completition(error, true)
                    
                } else {
                    print("email is not verified")
                    completition(error, false)
                }
            } else {
                completition(error, false)
            }
        }
    }
    
    //MARK: Register func

    class func registerUser(email: String, password: String, completition: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            completition(error)
            if error == nil {
                authDataResult?.user.sendEmailVerification{ (error) in
                    print("Auth Email Verification error: ", error?.localizedDescription)
                }
            }
        }
    }
    class func resentPasswordFor(email: String, completition: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            
        }
    }
    
    class func resendVerificationEmail(email: String, completition: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().currentUser?.reload(completion: { (error) in
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                
                //hata var ise
                print("resend email error: ",error?.localizedDescription)
                completition(error)
            })
        })
    }
    //MARK: helper to Logout function
    class func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {
        
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: kCURRENTUSER)
            UserDefaults.standard.synchronize()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
        
    }
    
}//end of class
    
    
func downloadUserFromFirestore(userId: String, email: String) {
    FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
        
        guard let snapshot = snapshot else { return }
        
        if snapshot.exists {
            print("download current user from firestore")
            saveUserLocally(mUserDictionary: snapshot.data()! as NSDictionary)
        } else {
            
            let user = MUser(_objectId: userId, _email: email, _firstName: "", _lastName: "")
            saveUserLocally(mUserDictionary: userDictionaryFrom(user: user))
                        
            saveUserToFirestore(mUser: user)
        }
    }
}




func saveUserToFirestore(mUser: MUser) {
    FirebaseReference(.User).document(mUser.objectId).setData(userDictionaryFrom(user: mUser) as! [String: Any]) { (error) in
        
        if error != nil {
            print("error saving user: ",error!.localizedDescription)
        }
    }
}

func saveUserLocally(mUserDictionary: NSDictionary) {
    
    UserDefaults.standard.set(mUserDictionary, forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
}




//MARK: Helper function
func userDictionaryFrom(user: MUser) -> NSDictionary {
    return NSDictionary(objects: [user.objectId, user.email, user.firstName, user.lastName, user.fullName, user.fullAdress ?? "", user.onBoard, user.purchasedItemIds], forKeys: [kOBJECTID as NSCopying, kEMAIL as NSCopying, kFIRSTNAME as NSCopying, kLASTTNAME as NSCopying, kFULLTNAME as NSCopying,kFULLADDRESS as NSCopying, kONBOARD as NSCopying, kPURCHASEDITEMIDS as NSCopying])
}



func updateCurrentUserInFirestore(withvalues: [String : Any], completition: @escaping (_ error: Error?) -> Void) {
 
    if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
        
        let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
        userObject.setValuesForKeys(withvalues) 
        FirebaseReference(.User).document(MUser.currentID()).updateData(withvalues) { (error) in
            completition(error)
            
            if error == nil {
                saveUserLocally(mUserDictionary: userObject)
            }
        }
    }
}
