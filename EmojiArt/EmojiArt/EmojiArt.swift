//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Soojung Shin on 2020/01/05.
//  Copyright © 2020 Soojung Shin. All rights reserved.
//

import Foundation

//모델로 사용할 EmojiArt 구조체이다.
struct EmojiArt {
    var url: URL
    var emojis = [EmojiInfo]()
    
    struct EmojiInfo {
        let x: Int
        let y: Int
        let text: String
        let size: Int
    }
    
    init(url: URL, emojis: [EmojiInfo]) {
        self.url = url
        self.emojis = emojis
    }
}
