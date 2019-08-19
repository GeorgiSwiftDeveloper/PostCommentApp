//
//  UpdateCommentVC.swift
//  myRandomProject
//
//  Created by Georgi Malkhasyan on 11/13/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import UIKit
import Firebase

class UpdateCommentVC: UIViewController {

    @IBOutlet weak var myCommentTxt: UITextView!
    @IBOutlet weak var updateButton: UIButton!
    
    
    
    var commentData: (comment: Comment, thought: Thought)!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myCommentTxt.layer.cornerRadius = 10
        updateButton.layer.cornerRadius = 10
       
        
        myCommentTxt.text = commentData.comment.comentTxt
    }
    

    @IBAction func updateTapped(_ sender: Any) {
        Firestore.firestore().collection("Post").document(commentData.thought.documentId).collection("comments").document(commentData.comment.documentId).updateData([COMMENT_TXT : myCommentTxt.text]) { (error) in
            if let error = error {
                print("Unable to update comment: \(error.localizedDescription)")
            }else {
               self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
