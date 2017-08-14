//
//  People.swift
//  SimpleSwift
//
//  Created by fuzhong on 2017/8/14.
//  Copyright © 2017年 fuzhong. All rights reserved.
//

import UIKit
import RealmSwift
class People: Object {
    
    dynamic var name = ""
    dynamic var id = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    //条目名
    
    
    //所属消费类别
    let dogs = List<Animal>()
}
