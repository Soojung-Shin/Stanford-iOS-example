//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Soojung Shin on 2019/12/22.
//  Copyright © 2019 Soojung Shin. All rights reserved.
//

import UIKit

class PlayingCardView: UIView {

    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: 16.0)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
    }
}
