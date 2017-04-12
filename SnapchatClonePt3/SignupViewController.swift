//
//  SignupViewController.swift
//  SnapchatClonePt3
//
//  Created by SAMEER SURESH on 3/19/17.
//  Copyright © 2017 iOS Decal. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
        TODO:
        
        Implement sign up functionality using the Firebase Auth create user function.
        If an error occurs, you should display an error message using a UIAlertController (e.g. if the password is less than 6 characters long). 
        Otherwise, using the user object that is returned from the createUser call, make a profile change request and set the user's displayName property to the name variable. 
        After committing the change request, you should perform a segue to the main screen using the identifier "signupToMain"
 
    */
    @IBAction func didAttemptSignup(_ sender: UIButton) {
        guard let email = emailField.text else { return }
        guard let password = passwordField.text else { return }
        guard let name = nameField.text else { return }
        // YOUR CODE HERE
        
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {
            (user, error) in
            if let error = error {
                let alert = UIAlertController(title: "Error!", message: "Could not sign up", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let changeRequest = user!.profileChangeRequest()
                changeRequest.displayName = name
                changeRequest.commitChanges(completion: {
                    (err) in
                    if let err = err {
                        let alert = UIAlertController(title: "Error!", message: "Could not sign up", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.performSegue(withIdentifier: "signupToMain", sender: self)
                    }
                })
            }
        })
        
        
//        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {(user, error) in
//            if let error = error {
//                let failedSignup = UIAlertController(title: "Failed to sign up.", message: "Please enter valid email and password.", preferredStyle: UIAlertControllerStyle.alert)
//                failedSignup.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//                self.present(failedSignup, animated:true)
//            } else {
//                let changeRequest = user!.profileChangeRequest()
//                changeRequest.displayName = name
//                changeRequest.commitChanges(completion: { (err) in
//                    if let err = err {
//                        let failedChange = UIAlertController(title: "Failed to switch users.", message: "Please enter valid email and password.", preferredStyle: UIAlertControllerStyle.alert)
//                        failedChange.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//                        self.present(failedChange, animated:true)
//                    } else {
//                        self.performSegue(withIdentifier: "signupToMain", sender: self)
//                    }
//                })
//            }
//        })
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
