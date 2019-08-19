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
    @IBOutlet var commentView: UIView!
    
    
    var thought: Thought!
    var comments  = [Comment]()
    var username: String!
    
    var thoughtRef: DocumentReference!
    let firestore = Firestore.firestore()
 
    var commentListener: ListenerRegistration!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        myTableView.delegate = self
        myTableView.dataSource = self
      
        
        thoughtRef = firestore.collection("Post").document(thought.documentId)
       
        if let name = Auth.auth().currentUser?.displayName {
            username = name
        }
        
        //View notification when Keyboard show
        self.commentView.bindToKeyboard()
        
    }
    //MARK: Displaying comments on the tableview
    override func viewDidAppear(_ animated: Bool) {
        commentListener = firestore.collection("Post").document(self.thought.documentId).collection("comments")
            .order(by: TIMESTAMP, descending: false)
            .addSnapshotListener({ (snapshot, error) in
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
    
    
    //Send Comments to the Firestore database  use Transaction
    @IBAction func addComentTapped(_ sender: Any) {
        guard let commentTxt = addCommentsTxt.text else {return}
        firestore.runTransaction({ (transaction, errorPointer) -> Any? in
            let thoughtDocument: DocumentSnapshot
            do{
                //Get documentId collection
                try thoughtDocument = transaction.getDocument(Firestore.firestore().collection("Post").document(self.thought.documentId))
            }catch{
                
               print("error")
                return nil
            }
            //MARK: GET NUN_COMMENTS and + 1 when comments added
            guard let oldNumComments = thoughtDocument.data()![NUM_COMMENTS] as? Int else {return nil}
            
            transaction.updateData([NUM_COMMENTS : oldNumComments + 1], forDocument: self.thoughtRef)
            
            //Create new collection on documentId collection
            let newCommentRef = self.firestore.collection("Post").document(self.thought.documentId).collection("comments").document()
            
            //Make collection "comments" with selected documentId and pass data to the Database
            transaction.setData([
                COMMENT_TXT : commentTxt,
                TIMESTAMP: FieldValue.serverTimestamp(),
                USERNAME : self.username,
                USER_ID: Auth.auth().currentUser?.uid
                ], forDocument: newCommentRef)
            return nil
        }) { (object, error) in
            if let error = error {
                print("transaction is failed\(error)")
            }else {
                self.addCommentsTxt.text = ""
                self.addCommentsTxt.bindToKeyboard()
            }
        }
    }
    

}

//MAKR: TableViewDelegate

extension CommentsVC: UITableViewDelegate, UITableViewDataSource, commentDelgate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if  let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as? CommentCell  {
            cell.configureCel(comments: comments[indexPath.row], delegate: self)
            
             return cell
        }
        
       return UITableViewCell()
    }
    
    
    //Delete and edit comments   function
    func commentOptionsTapped(comment: Comment) {
        print(comment.username)
        //UIAlertController for delete and edit
        let alert = UIAlertController(title: "Edit comment", message: "You can edit or delete ", preferredStyle: .actionSheet)
        
        let actionDelete = UIAlertAction(title: "Delete comment", style: .default) { (deleteaction) in
            self.firestore.runTransaction({ (transaction, errorPointer) -> Any? in
                let thoughtDocument: DocumentSnapshot!
                do{
                    try thoughtDocument = transaction.getDocument(Firestore.firestore().collection("Post").document(self.thought.documentId))
                }catch{
                    
                    print("error")
                    return nil
                }
                //MARK: GET NUN_COMMENTS and - 1 when comments deleted
                guard let oldNumComments = thoughtDocument.data()![NUM_COMMENTS] as? Int else {return nil}
                
                transaction.updateData([NUM_COMMENTS : oldNumComments - 1], forDocument: self.thoughtRef)
                
                let commentRef = self.firestore.collection("Post").document(self.thought.documentId).collection("comments").document(comment.documentId)
                transaction.deleteDocument(commentRef)
                return nil
            }) { (object, error) in
                if let error = error {
                    print("transaction is failed\(error)")
                }else {
                    print("Successfuly deleted")
                }
            }
        }
        let actionEdit = UIAlertAction(title: "Edit comment", style: .default) { (editaction) in
            self.performSegue(withIdentifier: "toEditComment", sender: (comment , self.thought))
            alert.dismiss(animated: true, completion: nil)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(actionEdit)
        alert.addAction(actionDelete)
        alert.addAction(actionCancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:Go to the updateVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UpdateCommentVC {
            if let commentData = sender as? (comment: Comment, thought: Thought) {
                destination.commentData = commentData
            }
        }
    }
    
}
