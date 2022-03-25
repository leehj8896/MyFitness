//
//  ViewController.swift
//  MyFitness
//
//  Created by HL on 2021/12/13.
//

import UIKit
import FSCalendar

class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    @IBOutlet var calendarView: FSCalendar!
    @IBOutlet var imgCollectionView: UICollectionView!
    
    let picker = UIImagePickerController()
    
    var events: [String] = []
    
    var imageData: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        calendarView.delegate = self
        calendarView.dataSource = self
        
        calendarView.appearance.headerDateFormat = "YYYY년 M월"
        calendarView.locale = Locale(identifier: "ko_KR")
        
        imgCollectionView.delegate = self
        imgCollectionView.dataSource = self
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 80, height: 80)
        imgCollectionView.collectionViewLayout = flowLayout
        
        picker.delegate = self
    
        let fileNames = getImageFileNames()
        for fileName in fileNames {
            if let image = getSavedImage(named: fileName) {
                let data: [String: Any] = ["name": fileName, "image": image]
                imageData.append(data)
            }
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        imgCollectionView.addGestureRecognizer(longPress)

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
            )
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
            print(error)
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! ImageCollectionViewCell
        
//        print("imageData[\(indexPath.row)]: \(imageData[indexPath.row])")
        if let test: UIImage = imageData[indexPath.row]["image"] as? UIImage {
            cell.imageView.image = test
        }
        
        return cell
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let current_date_string = formatter.string(from: Date())
            
            imageData.append(["name": "\(current_date_string).png", "image": image])
            imgCollectionView.reloadData()
            
            saveImage(image: image, named: current_date_string)
            print("사진 가져옴")
        }else{
            print("사진 없음")
        }
        
        picker.dismiss(animated: true, completion: nil)

    }
    
    func saveImage(image: UIImage, named: String) -> Bool {
        
        // 데이터 있으면
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        // 경로 있으면
        guard let directory = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false) as NSURL else {
            return false
        }
        
        // 저장
        do {
            try data.write(to: directory.appendingPathComponent("\(named).png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
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

