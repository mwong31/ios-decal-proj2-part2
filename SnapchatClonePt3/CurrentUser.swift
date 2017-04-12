//
//  CurrentUser.swift
//  SnapchatClonePt3
//
//  Created by SAMEER SURESH on 3/19/17.
//  Copyright © 2017 iOS Decal. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class CurrentUser {
    
    var username: String!
    var id: String!
    var readPostIDs: [String]?
    
    let dbRef = FIRDatabase.database().reference()
    
    init() {
        let currentUser = FIRAuth.auth()?.currentUser
        username = currentUser?.displayName
        id = currentUser?.uid
    }
    
    /*
        TODO:
        
        Retrieve a list of post ID's that the user has already opened and return them as an array of strings.
        Note that our database is set up to store a set of ID's under the readPosts node for each user.
        Make a query to Firebase using the 'observeSingleEvent' function (with 'of' parameter set to .value) and retrieve the snapshot that is returned. If the snapshot exists, store its value as a [String:AnyObject] dictionary and iterate through its keys, appending the value corresponding to that key to postArray each time. Finally, call completion(postArray).
    */
    func getReadPostIDs(completion: @escaping ([String]) -> Void) {
        var postArray: [String] = []
        // TODO
        dbRef.child(firUsersNode).child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                if let userDict = snapshot.value as? [String : AnyObject] {
                    for item in userDict.keys {
                        postArray.append(item)
                    }
                }
            }
        
        })
        completion(postArray)
        

        
    }
    
    /*
        TODO:
     
        Adds a new post ID to the list of post ID's under the user's readPosts node.
        This should be fairly simple - just create a new child by auto ID under the readPosts node and set its value to the postID (string).
        Remember to be very careful about following the structure of the User node before writing any data!
    */
    func addNewReadPost(postID: String) {
        dbRef.child(firUsersNode).child(username).setValue([firReadPostsNode: postID])
    }
    
}
