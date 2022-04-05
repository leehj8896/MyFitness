//
//  ViewController.swift
//  MyFitness
//
//  Created by HL on 2021/12/13.
//

import UIKit
import FSCalendar
import CoreData

class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, isAbleToReceiveData {
    
    var container: NSPersistentContainer!

    @IBOutlet var calendarView: FSCalendar!
    @IBOutlet var imgCollectionView: UICollectionView!
    @IBOutlet var exerciseTableView: UITableView!
    
    let picker = UIImagePickerController()
    
    var events: [String] = []
    
    var imageData: [[String: Any]] = []
    var exerciseData: [String] = []
    var selectedDate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("메인 view did load")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
        
        calendarView.delegate = self
        calendarView.dataSource = self
        
        calendarView.appearance.headerDateFormat = "YYYY년 M월"
        calendarView.locale = Locale(identifier: "ko_KR")
        
        imgCollectionView.delegate = self
        imgCollectionView.dataSource = self
        
        exerciseTableView.delegate = self
        exerciseTableView.dataSource = self
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 80, height: 80)
        imgCollectionView.collectionViewLayout = flowLayout
        
        picker.delegate = self
                
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let current_date_string = formatter.string(from: Date())
        selectedDate = current_date_string
    
        let fileNames = getImageFileNames()
//        print("filenames: \(fileNames)")
        for fileName in fileNames {
            if let image = getSavedImage(named: fileName) {
                let data: [String: Any] = ["name": fileName, "image": image]
                imageData.append(data)
            }
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        imgCollectionView.addGestureRecognizer(longPress)
        
        do {
            let request = Exercise.fetchRequest()
            let startFormatter = DateFormatter()
            startFormatter.dateFormat = "yyyy-MM-dd"
            let startDate = startFormatter.date(from: selectedDate)
            let endDate = Date(timeInterval: 60*60*24, since: startDate!)
            request.predicate = NSPredicate(format: "(%@ <= createdBy) AND (createdBy < %@)", startDate! as CVarArg, endDate as CVarArg)
            let results = try self.container.viewContext.fetch(request)
            for element in results {
//                print("name: \(element.name!)")
                exerciseData.append(element.name!)
            }
        } catch {
            print(error)
        }
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: imgCollectionView)
            if let indexPath = imgCollectionView.indexPathForItem(at: touchPoint) {
                let name = imageData[indexPath.row]["name"]
                deleteImage(named: name as! String, onSuccess: {_ in })
                imageData.remove(at: indexPath.row)
                imgCollectionView.reloadData()
            }
        }
    }
    
    func deleteImage(named: String,
                     onSuccess: @escaping ((Bool) -> Void)) {
      guard let directory =
        try? FileManager.default.url(for: .documentDirectory,
                                     in: .userDomainMask,
                                     appropriateFor: nil,
                                     create: false) as NSURL
      else { return }
      do {
        if let docuPath = directory.path {
          let fileNames = try
            FileManager.default.contentsOfDirectory(atPath: docuPath)
          for fileName in fileNames {
            if fileName == named {
              let filePathName = "\(docuPath)/\(fileName)"
              try FileManager.default.removeItem(atPath: filePathName)
              onSuccess(true)
              return
            }
          }
        }
      } catch let error as NSError {
          print("Could not deleteImage🥺: \(error), \(error.userInfo)")
          onSuccess(false)
      }
    }

    
    func getImageFileNames() -> [String] {
        do {
            // Get the document directory url
            let documentDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            ).appendingPathComponent(selectedDate)
            
//            print("documentDirectory", documentDirectory.path)
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(
                at: documentDirectory,
                includingPropertiesForKeys: nil
            )
//            print("directoryContents:", directoryContents)
//            print("directoryContents의 타입은? \(type(of: directoryContents))")
            
            var fileNames: [String] = []
            for url in directoryContents {
                let fileName = url.lastPathComponent
                fileNames.append(fileName)
            }
            return fileNames
            
        } catch {
//            print(error)
        }
        return []
    }
    
    
    @IBAction func btnAddImage(_ sender: Any) {
        picker.sourceType = .camera
//        camera.allowsEditing = true
//        camera.cameraDevice = .rear
//        camera.cameraCaptureMode = .photo
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func btnAddImageFromAlbum(_ sender: Any) {
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    // 셀 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageData.count
    }
    
    // 셀 내용
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        
//        print("imageData[\(indexPath.row)]: \(imageData[indexPath.row])")
        if let test: UIImage = imageData[indexPath.row]["image"] as? UIImage {
            cell.imageView.image = test
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell", for: indexPath) as! ExerciseTableViewCell
        cell.lblTest.text = exerciseData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "exerciseDetail", sender: indexPath.row)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{

            let formatter = DateFormatter()
            formatter.dateFormat = "HH-mm-ss"
            let current_date_string = formatter.string(from: Date())
            
            imageData.append(["name": "\(current_date_string).png", "image": image])
            
            saveImage(image: image, named: current_date_string)

            imgCollectionView.reloadData()

//            print("사진 가져옴")
        }else{
//            print("사진 없음")
        }
        
        picker.dismiss(animated: true, completion: nil)

    }
    
    func saveImage(image: UIImage, named: String) {
        
        // 데이터 있으면
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {return}
        // 경로 있으면
//        guard let directory = try? FileManager.default.url(
//            for: .documentDirectory,
//            in: .userDomainMask,
//            appropriateFor: nil,
//            create: false).appendingPathComponent(selectedDate) as NSURL else {
//            return false
//        }
        
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

    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(selectedDate).appendingPathComponent(named).path)
        }
        return nil
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        // 선택 날짜 변경
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let current_date_string = formatter.string(from: date)
        selectedDate = current_date_string
        
        imageData = []
        let fileNames = getImageFileNames()
        for fileName in fileNames {
            if let image = getSavedImage(named: fileName) {
                let data: [String: Any] = ["name": fileName, "image": image]
                imageData.append(data)
            }
        }
        
        imgCollectionView.reloadData()
        
        
        do {
            let request = Exercise.fetchRequest()
            let startFormatter = DateFormatter()
            startFormatter.dateFormat = "yyyy-MM-dd"
            let startDate = startFormatter.date(from: selectedDate)
            let endDate = Date(timeInterval: 60*60*24, since: startDate!)
            request.predicate = NSPredicate(format: "(%@ <= createdBy) AND (createdBy < %@)", startDate! as CVarArg, endDate as CVarArg)
            let results = try self.container.viewContext.fetch(request)
            
            exerciseData = []
            for element in results {
//                print("name: \(element.name!)")
                exerciseData.append(element.name!)
            }
            exerciseTableView.reloadData()
        } catch {
            print(error)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func showPopup(_ sender: Any) {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "popup") as! AddExercisePopupViewController
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.delegate = self
        
        present(popupVC, animated: true, completion: nil)
    }
    
    func pass(data: String) {
        print("passed \(data)")
        
        let exerciseName = data
        
        // core data에 저장
        let entity = NSEntityDescription.entity(forEntityName: "Exercise", in: self.container.viewContext)
        let exercise = NSManagedObject(entity: entity!, insertInto: self.container.viewContext)

        let createFormatter = DateFormatter()
        createFormatter.dateFormat = "yyyy-MM-dd"
        let createdDate = createFormatter.date(from: selectedDate)
        exercise.setValue(createdDate, forKey: "createdBy")

        exercise.setValue(exerciseName, forKey: "name")
        do {
            try self.container.viewContext.save()
        } catch {
            print(error)
        }

        // array에 추가
        exerciseData.append(exerciseName)

        // 테이블뷰 리로드
        exerciseTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "exerciseDetail" {
            if let i = sender as? Int {
                let nextVC = segue.destination as! ExerciseViewController
                nextVC.test = exerciseData[i]
            }
        }
    }
    
//    // 이벤트 추가
//    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let current_date_string = formatter.string(from: date)
//
//        if events.contains(current_date_string) {
//            return 1
//        }
//
//        return 0
//    }

//    @IBAction func btnAdd(_ sender: Any) {
//        print("clicked button")
//        if let dateString = txtDate.text {
//            events.append(dateString)
//            calendarView.reloadData()
//        }
//    }
}

