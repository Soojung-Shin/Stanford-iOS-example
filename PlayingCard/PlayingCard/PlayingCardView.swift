//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Soojung Shin on 2019/12/22.
//  Copyright © 2019 Soojung Shin. All rights reserved.
//

import UIKit

class PlayingCardView: UIView {
    
    var rank: Int = 5 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var suit: String = "♥️" { didSet { setNeedsDisplay(); setNeedsLayout() } }
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
        return centeredAttributedString("\(rank)\n\(suit)", fontSize: 30)
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
    
    //서브뷰들을 배치하는 메소드. 화면에 변화가 있을 때(가로 모드 등) 시스템에 의해 실행된다.
    override func layoutSubviews() {
        super.layoutSubviews()
        configureCornerLabel(upperLeftCornerLabel)
        upperLeftCornerLabel.frame.origin = bounds.offsetBy(dx: 8, dy: 8).origin
        
        configureCornerLabel(lowerRightCornerLabel)
        lowerRightCornerLabel.frame.origin = bounds.offsetBy(dx: bounds.maxX - lowerRightCornerLabel.frame.size.width - 8, dy: bounds.maxY - lowerRightCornerLabel.frame.size.height - 8).origin
    }

    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: 16.0)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
    }
}
