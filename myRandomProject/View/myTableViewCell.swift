//
//  myTableViewCell.swift
//  myRandomProject
//
//  Created by Georgi Malkhasyan on 11/6/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import UIKit
import Firebase

//Delegate for edditing post
protocol ThoughtDelegate {
    func thoughtOptionsTapped(thought: Thought)
}
class myTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var postLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var chatImage: UIImageView!
    
    //Edit button
    @IBOutlet weak var optionsMenu: UIImageView!
    @IBOutlet weak var chatLbl: UILabel!
    
    private var thought: Thought!
    private var delegate: ThoughtDelegate?
    
    
    
    //MARK: LIKE TAPPED
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeImage.addGestureRecognizer(tap)
        likeImage.isUserInteractionEnabled = true
    }
    
    //MARK: ADD LIKE ON POST
    @objc func likeTapped() {
      Firestore.firestore().collection("Post").document(thought.documentId)
        .setData([NUM_LIKES: thought.numLikes + 1 ], merge: true)
        
    }
    
    

    func configureCell(thought: Thought, delegate: ThoughtDelegate?) {
        optionsMenu.isHidden  = true
        self.thought = thought
        self.delegate = delegate
        userNameLbl.text = thought.username
        postLbl.text = thought.postTxt
        likeLbl.text = String(thought.numLikes)
        //MARK: FOR DATE  TIME FORMAT
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "MMM d, hh:mm"
        let timestamp = timeFormat.string(from: thought.timestamp)
        timestampLbl.text = timestamp
        chatLbl.text = String(thought.numComents)
        
        //Check if thought has userid then show optionsMenu
        if thought.userId == Auth.auth().currentUser?.uid {
            optionsMenu.isHidden = false
            optionsMenu.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(thoughtOptionsTapped))
            optionsMenu.addGestureRecognizer(tap)
            
        }
    }
    
    @objc func thoughtOptionsTapped() {
        delegate?.thoughtOptionsTapped(thought: thought)
    }
}
