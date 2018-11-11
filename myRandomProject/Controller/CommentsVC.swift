//
//  CommentsVC.swift
//  myRandomProject
//
//  Created by Georgi Malkhasyan on 11/7/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import UIKit
import Firebase
class CommentsVC: UIViewController {
    
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var addCommentsTxt: UITextField!
    @IBOutlet weak var sendCommentBtn: UIButton!
    
    var thought: Thought!
    var comments  = [Comment]()
    var thoughtRef: DocumentReference!
    let firestore = Firestore.firestore()
    var username: String!
    var commentListener: ListenerRegistration!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        myTableView.delegate = self
        myTableView.dataSource = self
        print(thought.postTxt)
        
        thoughtRef = firestore.collection("Post").document(thought.documentId)
       
        if let name = Auth.auth().currentUser?.displayName {
            username = name
        }
        
    }
    /////MARK: Displaying comments on the tableview
    override func viewDidAppear(_ animated: Bool) {
        commentListener = firestore.collection("Post").document(self.thought.documentId).collection("comments").addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching comments \(error)")
                return
            }
            self.comments.removeAll()
            self.comments = Comment.parseData(snapshot: snapshot)
            self.myTableView.reloadData()
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        commentListener.remove()
    }
    
    //MARK: how to use  TRANSACTION
    
    //Send Comments to the Firestore database 
    @IBAction func addComentTapped(_ sender: Any) {
        guard let commentTxt = addCommentsTxt.text else {return}
        
        firestore.runTransaction({ (transaction, errorPointer) -> Any? in
            let thoughtDocument: DocumentSnapshot!
            do{
                try thoughtDocument = transaction.getDocument(Firestore.firestore().collection("Post").document(self.thought.documentId))
            }catch{
                
               print("error")
                return nil
            }
            
            guard let oldNumComments = thoughtDocument.data()![NUM_COMMENTS] as? Int else {return nil}
            
            transaction.updateData([NUM_COMMENTS : oldNumComments + 1], forDocument: self.thoughtRef)
            
            let newCommentRef = self.firestore.collection("Post").document(self.thought.documentId).collection("comments").document()
            
            transaction.setData([
                COMMENT_TXT : commentTxt,
                TIMESTAMP: FieldValue.serverTimestamp(),
                USERNAME : self.username
                ], forDocument: newCommentRef)
            return nil
        }) { (object, error) in
            if let error = error {
                print("transaction is failed\(error)")
            }else {
                self.addCommentsTxt.text = ""
            }
        }
    }
    

}

extension CommentsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if  let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as? CommentCell  {
            cell.configureCel(comments: comments[indexPath.row])
            
             return cell
        }
        
       return UITableViewCell()
    }
    
    
}
