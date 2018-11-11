//
//  ViewController.swift
//  myRandomProject
//
//  Created by Georgi Malkhasyan on 11/5/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import UIKit
import Firebase

enum postCategory : String {
    case funny = "funny"
    case serious = "serious"
    case crazy = "crazy"
    case popular = "popular"
}

//
class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var myTableView: UITableView!
    
    
    
    private var thoughts = [Thought]()
    private var thoughtsCollectionREF: CollectionReference!
    private var thoughtsListener: ListenerRegistration!
    private var selectedCategory =  postCategory.funny.rawValue
    private var handler: AuthStateDidChangeListenerHandle?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        myTableView.estimatedRowHeight = 80
        myTableView.rowHeight = UITableView.automaticDimension
   
        thoughtsCollectionREF =  Firestore.firestore().collection("Post")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if thoughtsListener != nil  {
            thoughtsListener.remove()
        }
        
    }
    //MAKR: Check user Login ..
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        handler = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil  {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
                self.present(loginVC, animated: true, completion: nil)
            }else {
                self.setListener()
            }
        })
    }
    
    
    @IBAction func logOutTapped(_ sender: Any) {
        do{
           try Auth.auth().signOut()
        }catch{
            print("Error cant logout")
        }
    }
    @IBAction func selectedCategory(_ sender: Any) {
        switch segmentControll.selectedSegmentIndex {
        case 0:
            selectedCategory = postCategory.funny.rawValue
        case 1:
            selectedCategory  = postCategory.serious.rawValue
        case 2:
            selectedCategory = postCategory.crazy.rawValue
        default:
            selectedCategory = postCategory.popular.rawValue
        }
        thoughtsListener.remove()
        setListener()
        
    }
    //MARK: Fetching data from Firestore
  
    
    //MARK: Fetch data from Firestore
        func setListener() {
            if selectedCategory == postCategory.popular.rawValue {
                thoughtsListener =  thoughtsCollectionREF
                    .order(by: NUM_LIKES, descending: true)
                    .addSnapshotListener { (snapshot, err) in
                        
                        if let err = err {
                            print("error")
                        }else {
                            self.thoughts.removeAll()
                           self.thoughts = Thought.parseData(snapshot: snapshot)
                            self.myTableView.reloadData()
                        }
                }
            }else {
                thoughtsListener =  thoughtsCollectionREF
                    .whereField(CATEGORY, isEqualTo: selectedCategory)
                    .order(by: TIMESTAMP, descending: true)
                    .addSnapshotListener { (snapshot, err) in
                        if let err = err {
                            print("error")
                        }else {
                            self.thoughts.removeAll()
                           self.thoughts = Thought.parseData(snapshot: snapshot)
                            self.myTableView.reloadData()
                        }
                }
            }
            
            
        
 
    }
    
    //MARK: TableView  Protocols
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thoughts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as? myTableViewCell
        cell!.configureCell(thought: thoughts[indexPath.row])
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "commentsVC", sender: thoughts[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentsVC" {
            if let destinationVC  = segue.destination as? CommentsVC {
                if let thought = sender as? Thought {
                    destinationVC.thought = thought
                }
            }
        }
    }

}

