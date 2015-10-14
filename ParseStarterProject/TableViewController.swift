//
//  TableViewController.swift
//  Instagram-Clone-Swift
//
//  Created by Anil Allewar on 10/6/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController {
   
    var users:[PFObject] = []
    var followingList:[PFObject] = []
    
    @IBOutlet var userTableView: UITableView!
    
    var refresher:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add the refresher
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull down to refresh")
        refresher.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
        // Add the refresher as a sub view on the tableview
        self.userTableView.addSubview(refresher)
        
        if let _ = PFUser.currentUser()!.objectId {
            // Call function to load data
            self.loadUsers()
        }
    }
    
    //Function used to load the users on first view load or when the UI refresh is performed
    private func loadUsers(){
        // First clear the existing arrays
        self.users.removeAll(keepCapacity: true)
        self.followingList.removeAll(keepCapacity: true)
        
        //Get all user's except the logged in user
        let query = PFUser.query()
        query?.whereKey("username", notEqualTo: (PFUser.currentUser()?.username)!)
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let userList = objects {
                self.users = userList
                
                // Now get the following data for the current user
                let query = PFQuery(className: "Followers")
                query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
                
                query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    if let following = objects {
                        self.followingList = following
                        self.userTableView.reloadData()
                    } else if error != nil {
                        self.showAlert("Error getting following", message: error!.localizedDescription)
                    }
                })
                
            } else if error != nil {
                self.showAlert("Error getting users", message: error!.localizedDescription)
            }
        })
    }

    func refreshData() -> Void {
        self.loadUsers()
        self.refresher.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if let currentUser = users[indexPath.row] as? PFUser {
            cell.textLabel?.text = currentUser.username
            
            for following in followingList {
                if following["following"] as? String == currentUser.objectId {
                    //Add checkbox to cell
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    break
                }
            }
            
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let selectedUser = users[indexPath.row] as? PFUser {
            // Now get the following/following data for the current user
            let query = PFQuery(className: "Followers")
            query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
            query.whereKey("following", equalTo: (selectedUser.objectId)!)
            
            query.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                if error != nil && object == nil {
                    // Means the record doesn't exist
                    self.insertFollowingRecord(selectedUser, selectedIndexPath: indexPath)
                } else {
                    // Means record is present, so we will delete it
                    if let followingObject = object {
                        followingObject.deleteInBackground()
                    
                        let cell:UITableViewCell = self.userTableView.cellForRowAtIndexPath(indexPath)!
                        //Remove checkbox from cell
                        cell.accessoryType = UITableViewCellAccessoryType.None
                    }
                }
            })
        }
    }
    
    private func insertFollowingRecord (selectedUser:PFUser, selectedIndexPath: NSIndexPath) -> Void {
        // Now add the data for following in parse
        let following:PFObject = PFObject(className: "Followers")
        following["following"] = selectedUser.objectId
        following["follower"] = PFUser.currentUser()?.objectId
        
        following.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                let cell:UITableViewCell = self.userTableView.cellForRowAtIndexPath(selectedIndexPath)!
                //Add checkbox to cell
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else if error != nil {
                self.showAlert("Error following", message: error!.localizedDescription)
            }
        })
    }
    
    private func showAlert (title:String, message:String) ->Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifer = segue.identifier {
            if segueIdentifer == "logOut" {
                PFUser.logOut()
                let viewController:ViewController = segue.destinationViewController as! ViewController
                viewController.navigationItem.hidesBackButton = true
                
            }
        }
    }
}
