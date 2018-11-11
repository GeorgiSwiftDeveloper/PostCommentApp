//
//  myTableViewCell.swift
//  myRandomProject
//
//  Created by Georgi Malkhasyan on 11/6/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import UIKit
import Firebase
class myTableViewCell: UITableViewCell {
//tableviewcellsdfdsf
    @IBOutlet weak var userNameLbl: UILabel!
    //
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var postLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var chatImage: UIImageView!
    
    @IBOutlet weak var chatLbl: UILabel!
    private var myThought: Thought!
    
    
    //MARK: LIKE TAPPED
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeImage.addGestureRecognizer(tap)
        likeImage.isUserInteractionEnabled = true
    }
    
    //MARK: ADD LIKE ON POST
    @objc func likeTapped() {
      Firestore.firestore().collection("Post").document(myThought.documentId)
        .setData([NUM_LIKES: myThought.numLikes + 1 ], merge: true)
        
    }
    
    

    func configureCell(thought: Thought) {
       self.myThought = thought
       userNameLbl.text = thought.username
        postLbl.text = thought.postTxt
        likeLbl.text = String(thought.numLikes)
        //MARK: FOR DATE FORMAT
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "MMM d, hh:mm"
        let timestamp = timeFormat.string(from: thought.timestamp)
        timestampLbl.text = timestamp
        chatLbl.text = String(thought.numComents)
        
    }
}
