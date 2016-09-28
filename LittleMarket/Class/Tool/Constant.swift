//
//  Constant.swift
//  LittleMarket
//
//  Created by J on 16/9/20.
//  Copyright © 2016年 J. All rights reserved.
//

import UIKit
import Alamofire

let ScreenBounds = UIScreen.main.bounds
let ScreenWidth = ScreenBounds.width
let ScreenHeight = ScreenBounds.height

let BarHeight = UIApplication.shared.statusBarFrame.height

let Judge = OS.test // 运行模式


enum OS{
    case test
    case debug
    case run
}

struct ArticleCagetory {
    static let categoryDict = [
        "archive": "历史精华",
        
    ]
}

struct CellReuseIdentifier {
    static let MyGrid = "MyGrid"
    static let FindGrid = "FindGrid"
    static let OtherGrid = "OtherGrid"
    
    static let UserInfo = "UserInfo"
    static let UserMenu = "UserMenu"
    static let UserGrid = "UserGrid"
    static let UserDetail = "UserDetail"
    
    
}

struct SegueId {
    static let PopoverSortOrderMenu = "PopoverSortOrderMenu"
    
}

struct API {
    static let APIHost = "http://112.124.30.42:8686/api/"
    static let LoginAPI = API.APIHost + "User/GetLogin"
    static let MyGirdAPI = API.APIHost + "Progress/GetRileiDetail"
    static let FindGirdAPI = API.APIHost + "Progress/GetRileiDetail"
    static let OtherGirdAPI = API.APIHost + "Progress/GetRileiDetail"
}
