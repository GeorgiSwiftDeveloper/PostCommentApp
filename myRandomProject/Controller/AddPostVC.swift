//
//  AddPostVC.swift
//  myRandomProject
//
//  Created by Georgi Malkhasyan on 11/5/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import UIKit
import Firebase



class AddPostVC: UIViewController, UITextViewDelegate {
    @IBOutlet weak var categorySegment: UISegmentedControl!
    
    @IBOutlet weak var userNameTxt: UITextField!
    @IBOutlet weak var postTxt: UITextView!
    @IBOutlet weak var buttonPost: UIButton!
    
    
    

    
 private   var selectedCategory = postCategory.funny.rawValue
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonPost.layer.cornerRadius = 4
        postTxt.layer.cornerRadius = 4
        
        postTxt.delegate = self
        postTxt.text = "My Post"
        postTxt.textColor = UIColor.lightGray
        
        userNameTxt.text = Auth.auth().currentUser?.displayName
    }
    
    
    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        
        
    }
    //MARK: TextView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        postTxt.text = ""
        postTxt.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    //MARK: Selectedsegment
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        switch categorySegment.selectedSegmentIndex {
        case 0:
           selectedCategory = postCategory.funny.rawValue
        case 1:
           selectedCategory  = postCategory.serious.rawValue
        default:
            selectedCategory = postCategory.crazy.rawValue
        }
    }
   // //MARK:  Make database entry on Firestore send data 
    @IBAction func buttonPressedAction(_ sender: UIButton) {
        
        guard let username = userNameTxt.text else {return}
        Firestore.firestore().collection("Post").addDocument(data: [
            CATEGORY  : selectedCategory,
            NUM_COMMENTS: 0,
            NUM_LIKES: 0,
            POST_TXT: postTxt.text,
            TIMESTAMP: FieldValue.serverTimestamp(),
            USERNAME: username,
            USER_ID: Auth.auth().currentUser?.uid  ?? ""
        ]) { (error) in
            if let err = error {
                print("error adding document")
            }else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
}
