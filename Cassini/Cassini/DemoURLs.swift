//
//  DemoURLs.swift
//  Cassini
//
//  Created by Soojung Shin on 2019/12/30.
//  Copyright © 2019 Soojung Shin. All rights reserved.
//

import Foundation

struct DemoURLs
{
    static var NASA: Dictionary<String, URL> = {
        let NASAURLStrings = [
            "Cassini" : "https://www.jpl.nasa.gov/images/cassini/20090202/pia03883-full.jpg",
            "Earth" : "https://vignette.wikia.nocookie.net/verse-and-dimensions/images/3/36/Earth.jpg/revision/latest?cb=20170612153302",
            "Saturn" : "https://image.businessinsider.com/5d9b9b4fee40e439eb63de52?width=1100&format=jpeg&auto=webp"
        ]
        var urls = Dictionary<String,URL>()
        for (key, value) in NASAURLStrings {
            urls[key] = URL(string: value)
        }
        return urls
    }()
}
