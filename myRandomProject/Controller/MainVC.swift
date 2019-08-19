//
//  ViewController.swift
//  myRandomProject
//
//  Created by Georgi Malkhasyan on 11/5/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import UIKit
import Firebase

//data for selectedSegment
enum postCategory : String {
    case funny = "funny"
    case serious = "serious"
    case crazy = "crazy"
    case popular = "popular"
}
class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ThoughtDelegate {
    
    
    
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
        
        
        //TableView estiamte Height automaticly
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
    
    //Curent user logOut func
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
    
    //MARK: Fetch data from Firestore order by count of likes
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
                //MARK: Fetch data from Firestore  by category
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
    
    //Delete and editing  Posts userId  function
    
    func thoughtOptionsTapped(thought: Thought) {
       let alert = UIAlertController(title: "Delete Post", message: "Do  u wont to delete Post", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
            //delete post and Comments together
            self.delete(collection: Firestore.firestore().collection("Post").document(thought.documentId).collection("comments"), batchSize: 10)
            
            //Post delete
            Firestore.firestore().collection("Post").document(thought.documentId).delete(completion: { (error) in
                if let err = error {
                    print("Could not delete Post\(err.localizedDescription)")
                }else {
                    alert.dismiss(animated: true, completion: nil)
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
 
    //Firestore delete subcollection swift code
    func delete(collection: CollectionReference, batchSize: Int = 100) {
        // Limit query to avoid out-of-memory errors on large collections.
        // When deleting a collection guaranteed to fit in memory, batching can be avoided entirely.
        collection.limit(to: batchSize).getDocuments { (docset, error) in
            // An error occurred.
            let docset = docset
            
            let batch = collection.firestore.batch()
            docset?.documents.forEach { batch.deleteDocument($0.reference) }
            
            batch.commit {_ in
                self.delete(collection: collection, batchSize: batchSize)
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
        cell!.configureCell(thought: thoughts[indexPath.row], delegate: self)
        
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

