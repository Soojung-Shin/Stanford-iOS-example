//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Soojung Shin on 2020/01/01.
//  Copyright © 2020 Soojung Shin. All rights reserved.
//

import UIKit

class EmojiArtView: UIView {

    //backgroundImage의 값이 바뀌면 호출 되는 Computed Property를 넣는다. 이미지를 그리도록 setNeedsDisplay() 메소드를 호출한다.
    var backgroundImage: UIImage? { didSet{ setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        //backgroundImage를 뷰 경계에 맞춰 그린다.
        backgroundImage?.draw(in: bounds)
    }
}
