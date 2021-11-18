//
//  NewsTitle.swift
//  ITSC
//
//  Created by nju on 2021/11/16.
//

import UIKit

class News: NSObject {
    
    var title:String
    var timeStamp:String
    var link: String
    
    init(title: String, timeStamp: String, link: String) {
        self.title = title
        self.timeStamp = timeStamp
        self.link = link
    }

}
