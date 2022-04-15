//
//  AddFoodViewController.swift
//  MyFitness
//
//  Created by HL on 2022/04/12.
//

import UIKit
import CoreData

protocol isAbleToUpdateFoodData {
  func reloadFoodData()
}

class AddFoodViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet var txtFoodName: UITextField!
    @IBOutlet var txtFoodCalorie: UITextField!
    @IBOutlet var foodImageView: UIImageView!
    @IBOutlet var txtTime: UITextField!
    
    var delegate: isAbleToUpdateFoodData?
    
    var container: NSPersistentContainer!

    var foodImage: UIImage?
    
    var selectedDate: String?
    
    let picker = UIImagePickerController()
    
    var dayOrNight: [String] = ["오전", "오후"]
    var hours: [String] = []
    var minutes: [String] = []
    
    var selectedDayOrNight: String = "오전"
    var selectedHours: String = "0"
    var selectedMinutes: String = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer

        picker.delegate = self
        
        for i in 0 ..< 12 {
            hours.append("\(i)")
        }
        for i in 0 ..< 24 {
            minutes.append("\(i)")
        }
        
        txtTime.tintColor = .clear
        
        createPickerView()
        dismissPickerView()
    }
    
    @IBAction func useCamera(_ sender: UIButton) {
        picker.sourceType = .camera
//        camera.allowsEditing = true
//        camera.cameraDevice = .rear
//        camera.cameraCaptureMode = .photo
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func useAlbum(_ sender: UIButton) {
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func saveFood(_ sender: UIButton) {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH-mm-ss"
//        let current_date_string = formatter.string(from: Date())
//        print("current date string: \(current_date_string)")
        
        let fileName = UUID().uuidString
        guard let foodName = txtFoodName.text else {return}
        guard let calorieString = txtFoodCalorie.text else {return}
        guard let calorie = Int(calorieString) else {return}
        guard let image = foodImage else {return}
        guard let _ = txtTime.text else {return}
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        var dateString = selectedDate!
        if selectedDayOrNight == "오전" {
            dateString += " \(selectedHours):\(selectedMinutes)"
        }else if selectedDayOrNight == "오후" {
            dateString += " \(Int(selectedHours)!+12):\(selectedMinutes)"
        }
        let date = df.date(from: dateString)
        
        let foodDTO = FoodDTO()
        foodDTO.foodName = foodName
        foodDTO.fileName = fileName
        foodDTO.calorie = calorie
        foodDTO.date = date
        
        saveFoodData(foodDTO)
        saveFoodImage(selectedDate: selectedDate!, image: image, named: fileName)
        
        if let d = delegate {
            d.reloadFoodData()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return dayOrNight.count
        }else if component == 1 {
            return hours.count
        }else if component == 2 {
            return minutes.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return dayOrNight[row]
        }else if component == 1 {
            return hours[row]
        }else if component == 2 {
            return minutes[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedDayOrNight = dayOrNight[row]
        }else if component == 1 {
            selectedHours = hours[row]
        }else if component == 2 {
            selectedMinutes = minutes[row]
        }
    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        txtTime.inputView = pickerView
    }

    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let btnDone = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(self.onClickDone))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(self.onClickCancel))
        toolBar.setItems([btnCancel, space, btnDone], animated: true)
        toolBar.isUserInteractionEnabled = true
        txtTime.inputAccessoryView = toolBar
    }
    
    @objc func onClickDone() {
        txtTime.text = "\(selectedDayOrNight) \(selectedHours)시 \(selectedMinutes)분"
        txtTime.resignFirstResponder() // 피커뷰 내림
    }
    
    @objc func onClickCancel() {
        txtTime.resignFirstResponder() // 피커뷰 내림
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            foodImage = image
            foodImageView.image = foodImage
//            let formatter = DateFormatter()
//            formatter.dateFormat = "HH-mm-ss"
//            let current_date_string = formatter.string(from: Date())
//            imageData.append(["name": "\(current_date_string).png", "image": image])
//            saveImage(image: image, named: current_date_string)
//            imgCollectionView.reloadData()
//            print("사진 가져옴")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func saveFoodData(_ foodDTO: FoodDTO){
        // core data에 저장
        let entity = NSEntityDescription.entity(forEntityName: "Food", in: self.container.viewContext)
        let food = NSManagedObject(entity: entity!, insertInto: self.container.viewContext)

        food.setValue(foodDTO.fileName, forKey: "fileName")
        food.setValue(foodDTO.calorie, forKey: "calorie")
        food.setValue(foodDTO.foodName, forKey: "foodName")
        food.setValue(foodDTO.date, forKey: "date")
        
        do {
            try self.container.viewContext.save()
        } catch {
            print(error)
        }
    }
    
    func saveFoodImage(selectedDate: String, image: UIImage, named: String) {
        
        // 데이터 있으면
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {return}

        let directory = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false).appendingPathComponent(selectedDate)
        
        // 폴더 없으면 생성
        if !FileManager.default.fileExists(atPath: directory!.path) {
            do {
                try FileManager.default.createDirectory(atPath: directory!.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }

        // 저장
        do {
//            print("저장 디렉토리: \(directory!.path)")
            try data.write(to: directory!.appendingPathComponent("\(named).png"))
        } catch {
//            print(error.localizedDescription)
            print(error)
        }
    }

}
