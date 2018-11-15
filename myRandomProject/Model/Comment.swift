//
//  Comment.swift
//  myRandomProject
//
//  Created by Georgi Malkhasyan on 11/8/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import Foundation
import Firebase
//
class Comment {
    private(set) var username: String!
    private(set) var timestamp: Date!
    private(set) var comentTxt: String!
    private(set) var documentId: String!
    private(set) var userId: String!
 
    
    init(username:String,timestamp:Date,comentTxt: String, documentId: String, userId: String) {
        self.username = username
        self.timestamp = timestamp
        self.comentTxt = comentTxt
        self.documentId = documentId
        self.userId = userId
    }
    
    
    
    //Get comments  data from database  and put in on comments array
    class func parseData(snapshot: QuerySnapshot?) -> [Comment] {
        var comments = [Comment]()
        guard let snap = snapshot else {return comments}
        for  documents in snap.documents {
            let data =  documents.data()
            let username = data[USERNAME] as? String ?? "Any"
            let teimestamp = data[TIMESTAMP] as? Date ?? Date()
            let commentTxt = data[COMMENT_TXT] as? String ?? ""
            let documentId = documents.documentID
            let userId = data[USER_ID] as? String ?? ""
            let newComment = Comment(username: username, timestamp: teimestamp, comentTxt: commentTxt, documentId: documentId, userId: userId)

            comments.append(newComment)
        }
        return comments
    }
    
}
