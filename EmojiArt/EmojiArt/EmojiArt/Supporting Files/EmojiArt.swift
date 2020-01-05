//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Soojung Shin on 2020/01/05.
//  Copyright © 2020 Soojung Shin. All rights reserved.
//

import Foundation

//모델로 사용할 EmojiArt 구조체이다.
struct EmojiArt: Codable {
    var url: URL
    var emojis = [EmojiInfo]()
    
    struct EmojiInfo: Codable {
        let x: Int
        let y: Int
        let text: String
        let size: Int
    }
    
    //json 데이터를 받아와 디코딩하고, 자기자신에게 넣는 initializer.
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(EmojiArt.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    //해당 모델의 데이터를 JSON으로 인코딩한다.
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init(url: URL, emojis: [EmojiInfo]) {
        self.url = url
        self.emojis = emojis
    }
}
