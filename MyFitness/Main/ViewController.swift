//
//  ViewController.swift
//  MyFitness
//
//  Created by HL on 2021/12/13.
//

import UIKit
import FSCalendar
import CoreData

class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, isAbleToReceiveData, isAbleToUpdateFoodData {
    
    var container: NSPersistentContainer!

    @IBOutlet var calendarView: FSCalendar!
    @IBOutlet var imgCollectionView: UICollectionView!
    @IBOutlet var exerciseTableView: UITableView!
        
    var events: [String] = []
    
    var imageData: [[String: Any]] = []
    var exerciseData: [ExerciseDTO] = []
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
                
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let current_date_string = formatter.string(from: Date())
        selectedDate = current_date_string
            
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        imgCollectionView.addGestureRecognizer(longPress)
        
        fetchFoodData()
        fetchExerciseData(selectedDate)
    }
    
    func fetchExerciseData(_ selectedDate: String){
        do {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            let startDate = df.date(from: selectedDate)!
            let endDate = Date(timeInterval: 60*60*24, since: startDate)
            
            let request = Exercise.fetchRequest()
            request.predicate = NSPredicate(format: "(%@ <= date) AND (date < %@)", startDate as CVarArg, endDate as CVarArg)
            let results = try self.container.viewContext.fetch(request)
            
            // 데이터 추가
            exerciseData = []
            for exercise in results {
                let exerciseDTO = ExerciseDTO()
                exerciseDTO.id = exercise.id
                exerciseDTO.name = exercise.name
                exerciseDTO.date = exercise.date
                exerciseData.append(exerciseDTO)
            }
            exerciseTableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    func fetchFoodData() {
        imageData = []
        let fileNames = getImageFileNames()
        for fileName in fileNames {
            if let image = getSavedImage(named: fileName) {
                let data: [String: Any] = ["name": fileName, "image": image]
                imageData.append(data)
            }
        }
        imgCollectionView.reloadData()
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
        
    }
    
    @IBAction func btnAddImageFromAlbum(_ sender: Any) {
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
        
        let exerciseDTO = exerciseData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell", for: indexPath) as! ExerciseTableViewCell
        cell.lblExerciseCellTest.text = exerciseDTO.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "exerciseDetail", sender: indexPath.row)
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
        
//        imageData = []
//        let fileNames = getImageFileNames()
//        for fileName in fileNames {
//            if let image = getSavedImage(named: fileName) {
//                let data: [String: Any] = ["name": fileName, "image": image]
//                imageData.append(data)
//            }
//        }
//
//        imgCollectionView.reloadData()
        fetchFoodData()
        
        fetchExerciseData(selectedDate)
    }

    @IBAction func showPopup(_ sender: Any) {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "popup") as! AddExercisePopupViewController
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.delegate = self
        
        present(popupVC, animated: true, completion: nil)
    }
    
    func saveExerciseData(_ exerciseDTO: ExerciseDTO) {
        
        // core data에 저장
        let entity = NSEntityDescription.entity(forEntityName: "Exercise", in: self.container.viewContext)
        let exercise = NSManagedObject(entity: entity!, insertInto: self.container.viewContext)

        exercise.setValue(exerciseDTO.id, forKey: "id")
        exercise.setValue(exerciseDTO.name, forKey: "name")
        exercise.setValue(exerciseDTO.date, forKey: "date")
        
        do {
            try self.container.viewContext.save()
        } catch {
            print(error)
        }
    }
    
    func fromExercisePopup(exerciseName: String) {

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let date = df.date(from: selectedDate)
        
        let exerciseDTO = ExerciseDTO()
        exerciseDTO.id = UUID()
        exerciseDTO.name = exerciseName
        exerciseDTO.date = date
        
        saveExerciseData(exerciseDTO)

        // array에 추가
        exerciseData.append(exerciseDTO)

        // 테이블뷰 리로드
        exerciseTableView.reloadData()
    }
    
    // 데이터 주는 코드
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let i = sender as? Int {
            let exerciseDTO = exerciseData[i]
            if segue.identifier == "exerciseDetail" {
                let nextVC = segue.destination as! ExerciseViewController
                nextVC.exerciseDTO = exerciseDTO
            }
        }
        
        if segue.identifier == "addFood" {
            let nextVC = segue.destination as! AddFoodViewController
            nextVC.selectedDate = selectedDate
        }

    }
    
    func reloadFoodData() {
        fetchFoodData()
    }
    
    @IBAction func btnAddFood(_ sender: UIButton) {
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let addFoodVC = storyBoard.instantiateViewController(withIdentifier: "addFood") as! AddFoodViewController
        self.navigationController?.pushViewController(addFoodVC, animated: true)
        addFoodVC.delegate = self
        addFoodVC.selectedDate = self.selectedDate
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

