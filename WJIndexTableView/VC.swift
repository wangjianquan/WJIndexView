//
//  VC.swift
//  WJIndexTableView
//
//  Created by ulinix on 2017-12-27.
//  Copyright © 2017 wjq. All rights reserved.
//

import UIKit
import SnapKit


class Chice_Car: Decodable {
    let state: String?
    let title: String?
    let uptime: String?
    let up_time: String?
    let awat: [Car]
    let list: [Car]
    let access_token: String?
}

class Car: Decodable {
    let id: String?
    let title: String?
    let cn_title: String?
    let en_title: String?
    let thumb: String?
    let letter: String?
    
}

class VC: UIViewController {
    
    var tableView: UITableView = UITableView()
    var indexView: TableIndexView = TableIndexView()
    var focusedLabel: UILabel = UILabel()
    
    lazy var listArray: NSArray = NSArray()
    lazy var sectionArray = [String]()
    var alphaString: String?
    
    
    func setupView() {
        view.addSubview(tableView)
        view.addSubview(indexView)
        view.addSubview(focusedLabel)
        
        indexView.bringSubview(toFront: tableView)
        focusedLabel.sendSubview(toBack: tableView)
        
        focusedLabel.isHidden = true
        focusedLabel.font = UIFont.boldSystemFont(ofSize: 50)
        focusedLabel.textColor = .black
        focusedLabel.textAlignment = .center
        focusedLabel.highlightedTextColor = .white
        focusedLabel.backgroundColor = .color(.black, alpha: 0.3)
        focusedLabel.center = view.center

        indexView.delegate = self
        indexView.indexes = ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]
        
        tableView.snp.remakeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.leading.trailing.bottom.equalTo(view)
        }
        
        indexView.snp.remakeConstraints { (make) in
            make.top.equalTo(tableView).offset(66)
            make.bottom.equalTo(tableView).offset(-66)
            make.leftMargin.equalTo(tableView)
            make.width.equalTo(30)
        }
        
        focusedLabel.snp.remakeConstraints { (make) in
            make.centerX.equalTo(tableView)
            make.centerY.equalTo(tableView)
            make.size.equalTo(CGSize(width: 66, height: 66))
        }
    }
    
    let car = Car?.self
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        guard let url = URL(string: "http://192.168.199.200/index.php?m=version3&a=maxina_marka_list") else { return  }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in

            guard let data = data else {return}

            do {
                let chice_Car = try JSONDecoder().decode(Chice_Car.self, from: data)
               
                print("--------- \(chice_Car.list)")

            }catch{
                print(error)
            }

            }.resume()
        
        
    }
    
    func countFirstLetters(_ categoryArray: [NSString]) -> Int {
        var existingLetters = [String]()
        for name: NSString in categoryArray {
            let firstLetterInName: String = (name.substring(to: 0))
            let notAllowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
            let range: NSRange? = (firstLetterInName as NSString?)?.rangeOfCharacter(from: notAllowed)
            if !(existingLetters.contains(firstLetterInName ) && range?.location == NSNotFound) {
                existingLetters.append(firstLetterInName )
                alphaString = alphaString! + (firstLetterInName )
            }
        }
        return existingLetters.count
    }
 
   
   
    
}

extension VC: TableViewIndexDelegate {
    func focusedIndex(_ index: Int, title: String) {
        focusedLabel.bringSubview(toFront: self.tableView)
        focusedLabel.isHidden = false
        
        focusedLabel.text = title
        focusedLabel.isHighlighted = true
    }
    
    func focusEnded() {
        focusedLabel.sendSubview(toBack: self.tableView)
        focusedLabel.isHidden = true
    }
}
