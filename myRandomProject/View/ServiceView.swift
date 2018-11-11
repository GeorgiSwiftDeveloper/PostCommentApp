//
//  ServiceView.swift
//  myRandomProject
//
//  Created by Georgi Malkhasyan on 11/7/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import UIKit

class ServiceView: UIView {

    override func awakeFromNib() {
        self.layer.shadowOpacity = 0.90
        self.layer.shadowRadius = 7
        self.layer.shadowColor = UIColor.black.cgColor
        super.awakeFromNib()
    }

}
