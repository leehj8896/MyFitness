//
//  AddExercisePopupViewController.swift
//  MyFitness
//
//  Created by HL on 2022/04/05.
//

protocol isAbleToReceiveData {
  func fromExercisePopup(exerciseName: String)
}


import UIKit

class AddExercisePopupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var pickerView: UIPickerView!
    
    let pickerData: [String] = ["벤치프레스", "풀업", "스쿼트"]
    
    var delegate: isAbleToReceiveData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("팝업 view did load")
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    @IBAction func cancel(_ sender: Any) {
//        print("취소 클릭")
        self.dismiss(animated: true)
    }
    
    @IBAction func addExercise(_ sender: Any) {
//        print("추가 클릭")
        let selectedValue = pickerData[pickerView.selectedRow(inComponent: 0)]
        print("\(selectedValue) 선택")
        
        if let d = delegate {
            d.fromExercisePopup(exerciseName: selectedValue)
        }
        
        self.dismiss(animated: true)
    }
    
}
