//
//  SetsTableViewCell.swift
//  MyFitness
//
//  Created by HL on 2022/04/06.
//

import UIKit

class SetsTableViewCell: UITableViewCell {

    @IBOutlet var lblTime: UILabel!
    @IBOutlet var btnStart: UIButton!
    
    var count = 0.0
    
    var timer: Timer?
    
    @IBAction func startSet(_ sender: UIButton) {
        
        if let buttonTitle = sender.title(for: .normal) {
            if buttonTitle == "시작"{
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
                btnStart.setTitle("완료", for: .normal)
            }else if buttonTitle == "완료" {
                stopTimer()
                btnStart.setTitle("시작", for: .normal)
            }
        }
        
    }

    @objc func timerCallback() {
        // [처리할 로직 작성 실시]
        lblTime.text = String(count) // UI 카운트 값 표시 실시
        count += 0.01 // 1씩 카운트 값 증가 실시
        count = round(count * 100) / 100
    }

    func stopTimer(){
        // [실시간 반복 작업 중지]
        if timer != nil && timer!.isValid {
//            print("중지할거임")
            timer!.invalidate()
        }
    }

}
