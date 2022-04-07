//
//  ExerciseViewController.swift
//  MyFitness
//
//  Created by HL on 2022/04/03.
//

import UIKit

class ExerciseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet var txtRestTime: UITextField!
    @IBOutlet var btnStartOrEnd: UIButton!
    @IBOutlet var lblTest: UILabel!
    @IBOutlet var setsTableView: UITableView!
    
    var pageTitle: String?
    
    var setsData: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setsTableView.delegate = self
        setsTableView.dataSource = self

        if let t = pageTitle {
            lblTest.text = t
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setsCell", for: indexPath) as! SetsTableViewCell
//        cell.lblWeight.text = setsData[indexPath.row]
        return cell
    }
    
    @IBAction func addSets(_ sender: UIButton) {
        setsData.append("test")
        setsTableView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
