//
//  Post.swift
//  myRandomProject
//
//  Created by Georgi Malkhasyan on 11/6/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import Foundation
import Firebase

    
    class Thought {
        private(set) var username: String!
        private(set) var timestamp: Date!
        private(set) var postTxt: String!
        private(set) var numLikes: Int!
        private(set) var numComents: Int!
        private(set) var documentId: String!
        
        init(username:String,timestamp:Date,postTxt: String, numLikes: Int, numComents: Int, documentId: String) {
            self.username = username
            self.timestamp = timestamp
            self.postTxt = postTxt
            self.numLikes = numLikes
            self.numComents = numComents
            self.documentId = documentId
        }
        //MARK:  Take all data from Firestore and pass it on the init
        
        class func parseData(snapshot: QuerySnapshot?) -> [Thought] {
            var thoughts = [Thought]()
            guard let snap = snapshot else {return thoughts}
            for  documents in snap.documents {
                let data =  documents.data()
                let username = data[USERNAME] as? String ?? "Any"
                let teimestamp = data[TIMESTAMP] as? Date ?? Date()
                let postText = data[POST_TXT] as? String ?? ""
                let numlikes = data[NUM_LIKES] as? Int ?? 0
                let numcomments = data[NUM_COMMENTS] as? Int ?? 0
                let documentsId = documents.documentID
                
                let newDoc = Thought(username: username, timestamp: teimestamp, postTxt: postText, numLikes: numlikes, numComents: numcomments, documentId: documentsId)
                //MARK: Pass constant on the array of Thought
               thoughts.append(newDoc)
            }
            return thoughts
        }

}
