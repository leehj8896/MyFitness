//
//  ExerciseViewController.swift
//  MyFitness
//
//  Created by HL on 2022/04/03.
//

import UIKit
import CoreData

class ExerciseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var container: NSPersistentContainer!

    @IBOutlet var lblExerciseName: UILabel!
    @IBOutlet var txtReps: UITextField!
    @IBOutlet var txtWeight: UITextField!
    @IBOutlet var txtRestTime: UITextField!
    @IBOutlet var btnStartOrEnd: UIButton!
    @IBOutlet var setsTableView: UITableView!
    
//    var pageTitle: String?
//    var exerciseId: Int?
    var exerciseDTO: ExerciseDTO?
    
    var setsData: [SetDTO] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
        
        setsTableView.delegate = self
        setsTableView.dataSource = self
        
        if let exercise = exerciseDTO {
            lblExerciseName.text = exercise.name!
            fetchSetData(exercise.id!)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setsCell", for: indexPath) as! SetsTableViewCell
        
        let currSet = setsData[indexPath.row]
        cell.lblWeight.text = String(currSet.weight!)
        cell.lblReps.text = String(currSet.reps!)
        return cell
    }
    
    @IBAction func addSets(_ sender: UIButton) {
        if let weight = txtWeight.text, let reps = txtReps.text {
            if let w = Int(weight), let r = Int(reps) {
                
                let setDTO = SetDTO()
                setDTO.weight = w
                setDTO.reps = r
                setDTO.exerciseId = exerciseDTO!.id!
                
                saveSetData(setDTO)
                
                setsData.append(setDTO)
                setsTableView.reloadData()
                
                txtWeight.text = ""
                txtReps.text = ""
            }else {
                print("무게, 횟수 다시 입력")
            }
        }else {
            print("무게, 횟수 다시 입력")
        }
    }
    
    func saveSetData(_ setDTO: SetDTO) {
        // core data에 저장
        let entity = NSEntityDescription.entity(forEntityName: "OneSet", in: self.container.viewContext)
        let oneSet = NSManagedObject(entity: entity!, insertInto: self.container.viewContext)

        oneSet.setValue(setDTO.weight, forKey: "weight")
        oneSet.setValue(setDTO.reps, forKey: "reps")
        oneSet.setValue(setDTO.exerciseId, forKey: "exerciseId")
        
        do {
            try self.container.viewContext.save()
        } catch {
            print(error)
        }

    }
    
    func fetchSetData(_ exerciseId: UUID) {
        
        do {
            print("exerciseId: \(exerciseId)")
            let request = OneSet.fetchRequest()
            request.predicate = NSPredicate(format: "exerciseId = %@", exerciseId as CVarArg)
            
            let results = try self.container.viewContext.fetch(request)
            
            for oneSet in results {

                let setDTO = SetDTO()
                setDTO.weight = Int(oneSet.weight)
                setDTO.reps = Int(oneSet.reps)
                setDTO.exerciseId = oneSet.exerciseId
    
                setsData.append(setDTO)
                
                setsTableView.reloadData()
            }
        } catch {
            print(error)
        }
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }

}
