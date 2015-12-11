//
//  FeedTableViewController.swift
//  Instagram-Clone-Swift
//
//  Created by Anil Allewar on 10/13/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedTableViewController: UITableViewController {
    
    var followingUserPostsForCurrentUser:[PFObject] = []
    var allUsers = [String: String]()
    
    @IBOutlet var feedTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // First load the users as dictionary
        self.loadAllUsers()

        let followingUserQuery = PFQuery(className: "Followers")
        followingUserQuery.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
        
        followingUserQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let followingUsers = objects {
                for following in followingUsers {
                    if let followingCurrentUser = following["following"] as? String {
                        // Get posted images and add it to the instance level variable
                        let postedImagesForUserQuery = PFQuery(className: "UserImages")
                        postedImagesForUserQuery.whereKey("uploaderUser", equalTo: followingCurrentUser)
                        
                        postedImagesForUserQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                            if let objects = objects {
                                for object in objects {
                                    self.followingUserPostsForCurrentUser.append(object)
                                    // Reload the table now that the data has been loaded; this has to be called in the background block so that we refresh the table multiple times when the data is available
                                    self.feedTableView.reloadData()
                                }
                            }
                        })
                    }
                }
            }
        }
    }

    // Load all users
    private func loadAllUsers () -> Void {
        // Get all user's except the logged in user
        let userQuery = PFUser.query()!
        userQuery.whereKey("username", notEqualTo: (PFUser.currentUser()?.username)!)
        
        userQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let objects = objects {
                
                // Empty the array
                self.allUsers.removeAll(keepCapacity: true)
                self.followingUserPostsForCurrentUser.removeAll(keepCapacity: true)
                
                for object in objects {
                    if let user = object as? PFUser {
                        self.allUsers[user.objectId!] = user.username!
                    }
                }
            }

        }
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
        return self.followingUserPostsForCurrentUser.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FeedTableViewCell
        
        let userPost = self.followingUserPostsForCurrentUser[indexPath.row]
        
        // Get the username based on the object id
        cell.userLabel.text = allUsers[userPost["uploaderUser"] as! String]
        cell.commentLabel.text = userPost["comments"] as? String
        
        let imageFile:PFFile = userPost["imageFile"] as! PFFile
        
        imageFile.getDataInBackgroundWithBlock { (data, error ) -> Void in
            if let downloadedImage = UIImage(data : data!) {
                cell.postImageView.image = downloadedImage
            }
        }
        
        // Configure the cell...

        return cell
    }
}
