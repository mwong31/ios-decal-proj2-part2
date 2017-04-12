//
//  PostsTableViewController.swift
//  snapChatProject
//
//  Created by Paige Plander on 3/9/17.
//  Copyright © 2017 org.iosdecal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import MBProgressHUD

class PostsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum Constants {
        static let postBackgroundColor = UIColor.black
        static let postPhotoSize = UIScreen.main.bounds
    }
    
    // Dictionary that maps IDs of images to the actual UIImage data
    var loadedImagesById: [String:UIImage] = [:]
    
    
    let currentUser = CurrentUser()
    
    /// Table view holding all posts from each thread
    @IBOutlet weak var postTableView: UITableView!
    
    /// Button that displays the image of the post selected by the user
    var postImageViewButton: UIButton = {
        var button = UIButton(frame: Constants.postPhotoSize)
        button.backgroundColor = Constants.postBackgroundColor
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTableView.delegate = self
        postTableView.dataSource = self
        view.addSubview(postImageViewButton)
        
        postImageViewButton.addTarget(self, action: #selector(self.hidePostImage(sender:)), for: UIControlEvents.touchUpInside)
        
    }
    /*
        TODO:
        Call the function to retrieve data for our tableview.
        (Hint): This should be pretty simple.
    */
    override func viewWillAppear(_ animated: Bool) {
        // YOUR CODE HERE
        updateData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
        TODO:
        Use the 'getPosts' function to retrieve all of the posts in the database. You'll need to pass in the currentUser property declared above so that we know if the posts have been read or not.
        Using the posts variable that is returned, do the following:
        - First clear the current dictionary of posts (in case we're reloading this feed again). You can do this by calling the 'clearThreads' function.
        - For each post in the array:
            - Add the post to the thread using the 'addPostToThread' function
            - Using the postImagePath property of the post, retrieve the image data from the storage module (there is a function in ImageFeed.swift that does this for you already).
            - Create a UIImage from the data and add a new element to the 'loadedImagesById' variable using the image and post ID. 
        - After iterating through all the posts, reload the tableview.
     
    */
    func updateData() {
        // YOUR CODE HERE
        getPosts(user: currentUser, completion: { (posts) in
            clearThreads()
            for currPost in posts! {
                addPostToThread(post: currPost)
                getDataFromPath(path: currPost.postImagePath, completion: { (data) in
                    if data != nil {
                        let image = UIImage(data: data!)
                        self.loadedImagesById[currPost.postId] = image
                    }
                
                })
            }
            self.postTableView.reloadData()
        })
    }
    
    // MARK: Custom methods (relating to UI)
    
    func hidePostImage(sender: UIButton) {
        sender.isHidden = true
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    
    func presentPostImage(forPost post: Post) {
        // unhide the image view button so the user can see the post's image
        if let image = loadedImagesById[post.postId] {
            postImageViewButton.isHidden = false
            postImageViewButton.setImage(image, for: .normal)
            navigationController?.navigationBar.isHidden = true
            tabBarController?.tabBar.isHidden = true
        } else {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            getDataFromPath(path: post.postImagePath, completion: { (data) in
                if let data = data {
                    let image = UIImage(data: data)
                    self.loadedImagesById[post.postId] = image
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.postImageViewButton.isHidden = false
                    self.postImageViewButton.setImage(image, for: .normal)
                    // hide the navigation and tab bar for presentation
                    self.navigationController?.navigationBar.isHidden = true
                    self.tabBarController?.tabBar.isHidden = true
                }
            })
        }
    
    }
    
    // MARK: Table view delegate and datasource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return threadNames.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return threadNames[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostsTableViewCell
        if let post = getPostFromIndexPath(indexPath: indexPath) {
            if post.read {
                cell.readImageView.image = UIImage(named: "read")
            }
            else {
                cell.readImageView.image = UIImage(named: "unread")
            }
            cell.usernameLabel.text = post.username
            cell.timeElapsedLabel.text = post.getTimeElapsedString()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let threadName = threadNames[section]
        return threads[threadName]!.count
    }
    
    
    // TODO: add the selected post as one of the current user's read posts
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let post = getPostFromIndexPath(indexPath: indexPath), !post.read {
            presentPostImage(forPost: post)
            post.read = true
            
            // YOUR CODE HERE
        //FIRDatabase.database().reference().child(firUsersNode).child(currentUser.id).child(firReadPostsNode).setValue(post.postId)
            currentUser.addNewReadPost(postID: post.postId)
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
     
    }
    
}
