//
//  location.swift
//  gpsPracticeApp
//
//  Created by 坂口美月 on 2020/11/13.
//  Copyright © 2020 坂口美月. All rights reserved.
//

import Foundation

class User {
    
    var latitude:Any;
    var longitude:Any;
    var Name:Any;

    init(latitude:Any, longitude:Any,Name: Any) {
        self.latitude = latitude;
        self.longitude = longitude;
        self.Name = Name;
    }

   func toArray()->[Any] {
        return [self.latitude, self.longitude, self.Name];
    }
}
