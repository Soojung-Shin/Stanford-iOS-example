//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Soojung Shin on 2019/12/22.
//  Copyright © 2019 Soojung Shin. All rights reserved.
//

import UIKit

//@IBDesignable을 추가하면 스토리보드에서 코드로 추가한 뷰들을 확인할 수 있다.
@IBDesignable
class PlayingCardView: UIView {
    
    //변수에 @IBInspectable을 추가하면 해당 뷰의 attribute inspector에서 스토리보드에서 값을 변경, 확인할 수 있다.
    @IBInspectable
    var rank: Int = 5 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable
    var suit: String = "♠️" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable
    var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    //pinch 제스처로 이미지 크기를 조절하기 위해 변수를 추가한다. 중앙 이미지는 layout에 영향을 주는 UI가 아니기 때문에 setNeedsLayout()은 생략한다.
    var faceCardScale: CGFloat = SizeRatio.faceCardImageSizeToBoundsSize { didSet { setNeedsDisplay() } }
    
    //pinch 제스처로 실행되는 핸들러 메소드. pinch 제스처에 따라 카드 중앙의 이미지 크기를 변경한다.
    @objc func adjustFaceCardScale(byHandlingGestureRecognizedBy recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            //pinch의 비율에 따라 faceCardScale 값을 설정한다. 또한 계속 scale을 곱하면 너무 큰 값이 될 수 있으니 매번 pinch recognizer의 scale을 1.0으로 재설정해준다.
            faceCardScale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
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
    
    //카드의 숫자가 1~10일 경우 가운데 그려질 그림을 그리는 메소드
    private func drawPips() {
        let pipsPerRowForRank = [[0], [1], [1, 1], [1, 1, 1], [2, 2], [2, 1, 2], [2, 2, 2], [2, 1, 2, 2], [2, 2, 2, 2], [2, 2, 1, 2, 2], [2, 2, 2, 2, 2]]
        
        //함수 안에 함수를 넣을 수 있다.
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0) })
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0) })
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize / (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            } else {
                return probablyOkayPipString
            }
        }
        
        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                case 1:
                    pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }

    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        
        if isFaceUp {
            //카드 가운데에 해당 카드의 숫자에 맞는 이미지를 그린다.
            //해당 이미지의 in, compatibleWidth 파라미터는 스토리보드에서 UIImage(named:)로 추가된 이미지를 확인하기 위해 추가한 것이다.
            if let faceCardImage = UIImage(named: rankString + suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
            } else {
                drawPips()
            }
        } else {
            //카드가 face up 되어있지 않을 경우 카드의 뷰에 꽉차게 뒷면 이미지를 그린다.
            if let cardBackImage = UIImage(named: "cardback", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds)
            }
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
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width / 2, height: height)
    }
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width / 2, height: height)
    }
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
}
