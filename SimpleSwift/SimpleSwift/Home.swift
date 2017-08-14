//
//  Home.swift
//  SimpleSwift
//
//  Created by fuzhong on 2017/8/14.
//  Copyright © 2017年 fuzhong. All rights reserved.
//

import UIKit

class Home: NSObject {

    //条目名
    dynamic var name = ""
    //金额
    var addr:String?
    
    override init() {
        super.init()
    }
    
    init(name: String, add: String) {
        super.init()
        self.name = name
        self.addr = add
    }
}
