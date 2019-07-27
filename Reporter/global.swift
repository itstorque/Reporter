//
//  global.swift
//  Reporter
//
//  Created by Tareq El Dandachi on 7/16/18.
//  Copyright © 2018 Tareq El Dandachi. All rights reserved.
//

import UIKit

struct Constants {
    //                    0  1  2  3  4  5  6  7
    static let colors = [#colorLiteral(red: 0.8156862745, green: 0.007843137255, blue: 0.1058823529, alpha: 1),#colorLiteral(red: 0.3137254902, green: 0.8901960784, blue: 0.7607843137, alpha: 1),#colorLiteral(red: 0.9607843137, green: 0.6509803922, blue: 0.137254902, alpha: 1),#colorLiteral(red: 0.4941176471, green: 0.8274509804, blue: 0.1294117647, alpha: 1),#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 1, green: 0.06666666667, blue: 0.5725490196, alpha: 1),#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.2823529412, green: 0.6156862745, blue: 1, alpha: 1)]
    
    static let albumName = "Reporter"
    
    static let opacityFadeButton : Float = 0.8
    
    static let tabIndex = ["Evidence": 2, "Locations":1, "Recordings":0]
    
    static func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
}
