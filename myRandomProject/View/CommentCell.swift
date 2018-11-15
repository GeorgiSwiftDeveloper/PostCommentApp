//
//  CommentCell.swift
//  myRandomProject
//
//  Created by Georgi Malkhasyan on 11/8/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import UIKit
import Firebase

protocol commentDelgate {
    func commentOptionsTapped(comment: Comment)
}
class CommentCell: UITableViewCell {
//
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var optionsMenu: UIImageView!
    
    
    private var comment: Comment!
    private var delegate: commentDelgate?
    
    
    func configureCel(comments: Comment,delegate: commentDelgate) {
        self.comment = comments
        self.delegate = delegate
        usernameLbl.text = comments.username
        commentLbl.text = comments.comentTxt
        optionsMenu.isHidden = true
        
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "MMM d, hh:mm"
        let timestamp = timeFormat.string(from: comments.timestamp)
        dateLbl.text = timestamp
        
        
        if comments .userId == Auth.auth().currentUser?.uid {
            optionsMenu.isHidden = false
            optionsMenu.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(commentOptionsTapped))
            optionsMenu.addGestureRecognizer(tap)
        }
    }
    
    @objc func commentOptionsTapped() {
        delegate?.commentOptionsTapped(comment: comment)
    }
   

  
}
