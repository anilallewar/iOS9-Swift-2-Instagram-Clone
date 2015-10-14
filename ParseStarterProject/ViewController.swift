/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var username: UITextField!
    
    @IBOutlet var password: UITextField!
   
    @IBAction func logInClicked(sender: AnyObject) {
        // Show alert if either username or password is empty
        if (username.text!.isEmpty || password.text!.isEmpty) {
            self.showAlert("Error in input", message: "Please provide both username and password")
        } else {
            let activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center=self.view.center
            activityIndicator.hidesWhenStopped=true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var messageText = "Please try again later!"
            
            PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { (user, error) -> Void in
                // Stop the activity indicator and make the app usable again
                activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if error == nil {
                    // Navigate with identifier without using the segue
                    let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc:UINavigationController = storyboard.instantiateViewControllerWithIdentifier("nvc_TableViewController") as! UINavigationController
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(vc, animated: true, completion: nil)
                    })
                    /*
                    self.performSegueWithIdentifier("login", sender: self)
                    */
                } else {
                    if let errorString = error!.userInfo["error"] as? String {
                        messageText = errorString
                    }
                    
                    self.showAlert("Log In Status", message: messageText)
                }
            })
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the delegate for UI Text field
        self.username.delegate = self
        self.password.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // If the user is already logged in then take him directly to the user list
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser()?.username != nil{
            // Navigate with segue
            self.performSegueWithIdentifier("login", sender: self)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
