//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Soojung Shin on 2019/12/22.
//  Copyright © 2019 Soojung Shin. All rights reserved.
//

import UIKit

class PlayingCardView: UIView {
    
    var rank: Int = 11 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var suit: String = "♠️" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    //입력받은 String을 fontSize 크기로 조절하고, 가운데 정렬된 NSAttributedString으로 반환하는 메소드
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        //사용자가 설정에서 폰트 크기를 변경했을 때, 유동적으로 폰트 크기를 적용해준다.
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        
        //텍스트의 문단에 관련된 설정을 한다.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        return NSAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle, .font: font])
    }
    
    private var cornerString: NSAttributedString {
        return centeredAttributedString(rankString + "\n" + (suit), fontSize: cornerFontSize)
    }
    
    //초기화 되기 전에 인스턴스를 먼저 만들게 되므로 lazy 키워드를 사용한다.
    private lazy var upperLeftCornerLabel = createCornerLabel()
    private lazy var lowerRightCornerLabel = createCornerLabel()
    
    //CornerLabel에 UILabel 인스턴스를 생성해 하는 메소드
    private func createCornerLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    //카드의 왼쪽 상단, 오른쪽 하단에 올 글씨를 UILabel에 설정하고, 그 크기를 내부 텍스트에 맞게 조절하는 메소드
    private func configureCornerLabel(_ label: UILabel) {
        label.attributedText = cornerString
        //내부의 글자에 맞춰 UILabel의 크기를 조절하는 sizeToFit()은 width가 지정되었을 경우 width는 고정되고 height만 변경되기 때문에 해당 UILabel의 frame size를 zero로 리셋한다.
        label.frame.size = CGSize.zero
        label.sizeToFit()
        //카드가 앞면일 경우(isFaceUp이 true)에만 해당 UILabel이 보이도록 설정한다.
        label.isHidden = !isFaceUp
    }
    
    //특성이 바뀌었을 때, redraw한다.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    //서브뷰들을 배치하는 메소드. 화면에 변화가 있을 때(가로 모드 등) 시스템에 의해 실행된다.
    override func layoutSubviews() {
        super.layoutSubviews()
        configureCornerLabel(upperLeftCornerLabel)
        upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
        
        configureCornerLabel(lowerRightCornerLabel)
        //오른쪽 하단에 올 텍스트를 회전시킨다. 이때 해당 뷰의 원점(왼쪽 상단)을 기준으로 회전하기 때문에 위치가 변경될 수 있다. 그래서 원래의 위치에 놓고싶다면 회전과 평행이동을 동시에 해야한다. 맨 오른쪽 아래 점으로 이동시킨 후 파이만큼 회전시키면 원래 위치에서 회전된 모습을 볼 수 있다.
        lowerRightCornerLabel.transform = CGAffineTransform.identity
            .translatedBy(x: lowerRightCornerLabel.frame.size.width, y: lowerRightCornerLabel.frame.size.height)
            .rotated(by: CGFloat.pi)
        lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY)
            .offsetBy(dx: -cornerOffset, dy: -cornerOffset)
            .offsetBy(dx: -lowerRightCornerLabel.frame.size.width, dy: -lowerRightCornerLabel.frame.size.height)
    }

    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        
        //카드 가운데에 이미지를 추가한다.
        if let faceCardImage = UIImage(named: rankString + suit) {
            faceCardImage.draw(in: bounds.zoom(by: SizeRatio.faceCardImageSizeToBoundsSize))
        }
    }
}

//사용할 상수들을 extension으로 추가
extension PlayingCardView {
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    private var rankString: String {
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}

extension CGRect {
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
}
