//
//  CommentCell.swift
//  myRandomProject
//
//  Created by Georgi Malkhasyan on 11/8/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var commentLbl: UILabel!
    
    
    
    
    func configureCel(comments: Comment) {
        usernameLbl.text = comments.username
        commentLbl.text = comments.comentTxt
        
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "MMM d, hh:mm"
        let timestamp = timeFormat.string(from: comments.timestamp)
        dateLbl.text = timestamp
       
    }
   

  
}
