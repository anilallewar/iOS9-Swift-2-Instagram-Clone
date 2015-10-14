//
//  PostImageViewController.swift
//  Instagram-Clone-Swift
//
//  Created by Anil Allewar on 10/11/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class PostImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet var postImageView: UIImageView!
    
    @IBOutlet var commentText: UITextField!
    
    var activityIndicator : UIActivityIndicatorView!
    
    static let MAX_FILE_SIZE : Int = 10485760
    
    let dateFormatter = NSDateFormatter()
    
    @IBAction func chooseImageClicked(sender: AnyObject) {
        let imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imageController.allowsEditing = false
        
        // Add the image controller to be shown
        self.presentViewController(imageController, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        // Dismiss the existing modal view controller
        self.dismissViewControllerAnimated(true, completion: nil)
        // Show the image
        self.postImageView.image = image
    }
    
    @IBAction func uploadImageClicked(sender: AnyObject) {
        
        if self.commentText.text!.isEmpty {
            self.showAlert("Comment required", message: "Please add comments before uploading the image")
        } else {
            // Ensure that we are showing the greyed out screen for the whole frame
            activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            // Now save the image to parse
            self.saveImageObjectToParse()
            
        }
    }
    
    private func saveImageObjectToParse() -> Void{
        let currentTime = NSDate()
        let fileName = (PFUser.currentUser()?.username)! + "_" + self.dateFormatter.stringFromDate(currentTime) + ".jpg"
        
        let imageObject:PFObject = PFObject(className: "UserImages")
        imageObject["uploaderUser"] = PFUser.currentUser()?.objectId
        imageObject["uploadedDate"] = currentTime
        imageObject["comments"] = self.commentText.text
        imageObject["fileName"] = fileName
        
        if let imageData = UIImageJPEGRepresentation(self.postImageView.image!, 0.5) {
            // UIImageRepresentation can't handle more than 10MB file
            if imageData.length >= PostImageViewController.MAX_FILE_SIZE {
                showAlert("Large File", message: "The file to be uploaded can't have size more than 10 MB")
                return
            }
            
            let imageFile = PFFile(name: fileName, data: imageData)
            
            imageObject["imageFile"] = imageFile
            
            imageObject.saveInBackgroundWithBlock { (success, error) -> Void in
                if success {
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    // Set the image to original placeholder so that user knows that image has been uploaded
                    self.postImageView.image = UIImage(named: "placeholder.jpeg")
                    self.commentText.text = ""
                    
                    self.showAlert("Image Save", message: "Image saved successfully with id: \(imageObject.objectId)")
                } else if error != nil {
                    self.showAlert("Error saving image", message: (error?.localizedDescription)!)
                }
            }

        }
        
    }
    
    private func showAlert (title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Set the date formatter stype
        self.dateFormatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        
        self.commentText.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
