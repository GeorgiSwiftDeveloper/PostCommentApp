//
//  CreateUserViewController.swift
//  myRandomProject
//
//  Created by Georgi Malkhasyan on 11/7/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import UIKit
import Firebase
class CreateUserVC: UIViewController {

    @IBOutlet weak var emailTextFild: UITextField!
    
    @IBOutlet weak var passwordTextFild: UITextField!
    
    @IBOutlet weak var usernameTextFild: UITextField!
    
    
    @IBOutlet weak var createBtn: UIButton!
    
    @IBOutlet weak var cancelBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

      myButton()
    }
    
    func myButton() {
        createBtn.layer.cornerRadius = 10
        createBtn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        createBtn.layer.borderWidth = 1.0
        createBtn.layer.shadowOpacity = 0.90
        createBtn.layer.shadowRadius = 7
        createBtn.layer.shadowColor = UIColor.white.cgColor
        
        cancelBtn.layer.cornerRadius = 10
        cancelBtn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cancelBtn.layer.borderWidth = 1.0
        cancelBtn.layer.shadowOpacity = 0.90
        cancelBtn.layer.shadowRadius = 7
        cancelBtn.layer.shadowColor = UIColor.white.cgColor
    }
    
    //MARK: Create user account on Firestore
    @IBAction func createUserTapped(_ sender: Any) {
        
        guard let email = emailTextFild.text,
                let password = passwordTextFild.text,
        let username = usernameTextFild.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print("Error  cvreating user\(err.localizedDescription)")
            }
            
            let changeRequest = user?.user.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges(completion: { (error) in
                if let err = error {
                    print("error\(error?.localizedDescription)")
                }
            })
            guard let userId = user?.user.uid else {return}
            Firestore.firestore().collection(USER_REF).document(userId).setData([
                USERNAME : username,
                DATE_CREATED : FieldValue.serverTimestamp()
                ], completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }else {
                        self.dismiss(animated: true, completion: nil
                        )
                    }
            })
        }
    }
    

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
