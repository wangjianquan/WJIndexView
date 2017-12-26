//
//  ViewController.swift
//  WJIndexTableView
//
//  Created by ulinix on 2017-12-22.
//  Copyright © 2017 wjq. All rights reserved.
//

import UIKit

let Screen_Width =  UIScreen.main.bounds.size.width
let Screen_height = UIScreen.main.bounds.size.height

class ViewController: UIViewController {
   
    @IBOutlet weak var table: UITableView!
    
    fileprivate lazy var  memberLists:[String] = {
        let memberList = ["A","B","C","D","E","F","G","H","I","J","K","L","M","*"]
        return memberList
    }()
    
    lazy var indexView: WJIndexView = {
        let indexView = WJIndexView(frame: CGRect(x: 0, y: 0, width: Screen_Width, height: Screen_height-64))
        indexView.dataSource = self
        indexView.font = UIFont.systemFont(ofSize: 13)
        indexView.rightMargin = 30
        indexView.fontColor =  UIColor.red
        return indexView
    }()
    
    lazy var centerLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.font = UIFont.systemFont(ofSize: 30)
        label.backgroundColor = UIColor.green
        label.textColor = UIColor.red
        label.textAlignment = .center
        label.center = self.view.center
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.alpha=0;
//        view.addSubview(label)
          return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
       view.addSubview(indexView)
     
        
        table.register(UINib.init(nibName: "IndexCell", bundle: nil), forCellReuseIdentifier: "cell")
        
    }
    
   

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        touch(touches as NSSet)
//    }
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        touch(touches as NSSet)
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        UIView.animate(withDuration: 0.3) {
//            self.centerLabel.alpha = 0
//        }
//    }
//    func touch(_ touches: NSSet) {
//        UIView.animate(withDuration: 0.3) {
//            self.centerLabel.alpha = 1
//        }
//        let touch: UITouch = touches.anyObject() as! UITouch
//        let point = touch.location(in:nil)
//        let index: Int = Int(Int(point.y)*memberLists.count)
//        if index > memberLists.count-1 || index < 0 {
//            return
//        }
//        centerLabel.text  = memberLists[index] as? String
//        let indexpath: IndexPath = IndexPath(row: 0, section: index)
//        table .scrollToRow(at: indexpath, at: .top, animated: true)
//    }
}


extension ViewController : UITableViewDelegate, UITableViewDataSource, WJIndexViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return memberLists.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return 50
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: self.view.frame.size.width, height: 20))
        title.backgroundColor = UIColor.clear
        title.textAlignment = .left
        title.textColor = UIColor.gray
        title.font = UIFont.systemFont(ofSize: 14)
        let sectionTitle = memberLists[section]
        title.text = sectionTitle == "@" ? "管理员" : sectionTitle
        return title
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? IndexCell
        cell?.name.text = "\(memberLists[indexPath.row])"
        return cell!
    }
    
    func sectionIndexTitlesForMJNIndexView(_ indexView: WJIndexView) -> [String] {
        if memberLists.count > 0 {
            return memberLists
        }
        return [String]()
    }
    
    func sectionForSectionMJNIndexTitle(_ title: String, _ atIndex: NSInteger) {
        table?.scrollToRow(at: NSIndexPath.init(item: 0, section: atIndex) as IndexPath, at:.top , animated: (self.indexView.isGetSelectedItemsAfterPanGestureIsFinished))
    }
    
}
