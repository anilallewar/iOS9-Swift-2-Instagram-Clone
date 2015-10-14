//
//  SignUpViewController.swift
//  Instagram-Clone-Swift
//
//  Created by Anil Allewar on 10/13/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var userNameText: UITextField!
    
    @IBOutlet var passwordText: UITextField!

    @IBOutlet var retypePasswordText: UITextField!
    
    @IBOutlet var emailText: UITextField!
    
    @IBAction func signUpClicked(sender: AnyObject) {
        if userNameText.text!.isEmpty || passwordText.text!.isEmpty || retypePasswordText.text!.isEmpty || emailText.text!.isEmpty {
            self.showAlert("Required", message: "All the values are required")
        } else if passwordText.text! != retypePasswordText.text! {
            self.showAlert("Password different", message: "The password in both password and retype password fields must be same")
        } else {
            
            let activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center=self.view.center
            activityIndicator.hidesWhenStopped=true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            let signUpUser = PFUser()
            signUpUser.username = userNameText.text
            signUpUser.password = passwordText.text
            signUpUser.email = emailText.text
            
            var messageText = "Please try again later!"
            
            signUpUser.signUpInBackgroundWithBlock({ (success, error) -> Void in
                // Stop the activity indicator and make the app usable again
                activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if error == nil {
                    // Signup automatically logs in the user; hence we need to log him out
                    PFUser.logOut()
                    // Navigate with segue
                    self.performSegueWithIdentifier("backToLogin", sender: self)
                } else {
                    if let errorString = error!.userInfo["error"] as? String {
                        messageText = errorString
                    }
                    self.showAlert("Sign Up Status", message: messageText)
                }
            })
        }
    }
    
    @IBAction func cancelClicked(sender: AnyObject) {
        // Navigate with segue
        self.performSegueWithIdentifier("backToLogin", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.userNameText.delegate = self
        self.passwordText.delegate = self
        self.retypePasswordText.delegate = self
        self.emailText.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func showAlert (title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
