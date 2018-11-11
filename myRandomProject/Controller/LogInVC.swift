//
//  LoginViewController.swift
//  myRandomProject
//
//  Created by Georgi Malkhasyan on 11/7/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import UIKit
import Firebase
class LogInVC: UIViewController {

    @IBOutlet weak var emailTxt: Service!
    @IBOutlet weak var passwordTxt: Service!
    
    
    @IBOutlet weak var logInBtn: UIButton!
    @IBOutlet weak var passwordBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        myButtons()
    }
    
    func myButtons() {
        logInBtn.layer.cornerRadius = 10
        logInBtn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        logInBtn.layer.borderWidth = 2.0
        logInBtn.layer.shadowOpacity = 0.90
        logInBtn.layer.shadowRadius = 7
        logInBtn.layer.shadowColor = UIColor.white.cgColor
        
        passwordBtn.layer.cornerRadius = 10
        passwordBtn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        passwordBtn.layer.borderWidth = 2.0
        passwordBtn.layer.shadowOpacity = 0.90
        passwordBtn.layer.shadowRadius = 7
        passwordBtn.layer.shadowColor = UIColor.white.cgColor
    }
    

    @IBAction func logInButtonTapped(_ sender: Any) {
        guard let email = emailTxt.text,
            let password = passwordTxt.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print("Some error \(err.localizedDescription)")
            }else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    

    
}
