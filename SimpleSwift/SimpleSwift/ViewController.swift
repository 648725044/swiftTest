//
//  ViewController.swift
//  SimpleSwift
//
//  Created by fuzhong on 2017/8/14.
//  Copyright © 2017年 fuzhong. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    let realm = try! Realm()
    var consumeItems:Results<People>?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("test")
        
        let ss = Home(name: "雷克萨斯", add: "深圳")
        
        print("test:\(ss.name)")
        
        //test Realm
        testRealm()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func testRealm()  {
        
        // noe
        let p1 = People()
        p1.name = "lucy"
        p1.id = 1
        
        let d1 = Animal()
        d1.name = "哈士奇1"
        d1.cost = 2300.0
        
        let d2 = Animal()
        d2.name = "哈士奇2"
        d2.cost = 2340.0
        
        p1.dogs.append(d1)
        p1.dogs.append(d2)
        
        // two
        let p2 = People(value: ["Tecy",2])
        
        let d3 = Animal(value: ["泰迪",1820])
        let d4 = Animal(value: ["哈怕狗",1630])
        
        p2.dogs.append(d3)
        p2.dogs.append(d4)
        
        
        //three
        // two
        
        let d5 = Animal(value: ["藏獒",1820])
        let d6 = Animal(value: ["狼狗",1630])
        let p3 = People(value: ["Tecy",3,[d5,d6]])
        
       
        //write
        try! realm.write {
            
            realm.add(p1, update: true)
            realm.add(p2, update: true)
            realm.add(p3, update: true)
        }
        //打印出数据库地址
        print("------\(String(describing: realm.configuration.fileURL))")
   
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let realm = try! Realm()
        
        consumeItems = realm.objects(People.self)
        
        print("-----realm-----\(String(describing: consumeItems))")
    }
}

