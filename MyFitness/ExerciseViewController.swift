//
//  ExerciseViewController.swift
//  MyFitness
//
//  Created by HL on 2022/04/03.
//

import UIKit

class ExerciseViewController: UIViewController {

    @IBOutlet var txtRestTime: UITextField!
    @IBOutlet var txtWeight: UITextField!
    @IBOutlet var txtReps: UITextField!
    
    @IBOutlet var lblTest: UILabel!
    var test: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let t = test {
            lblTest.text = t
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func btnStart(_ sender: Any) {
    }
    
    @IBAction func btnEnd(_ sender: Any) {
    }
    
    
}
