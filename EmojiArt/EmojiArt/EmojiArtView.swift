//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Soojung Shin on 2020/01/01.
//  Copyright © 2020 Soojung Shin. All rights reserved.
//

import UIKit

class EmojiArtView: UIView, UIDropInteractionDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        addInteraction(UIDropInteraction(delegate: self))
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        //attributedString을 드롭하는 것을 항상 허용한다.
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { providers in
            let dropPoint = session.location(in: self)
            //providers를 NSAttributedString 배열로 캐스팅하고, 캐스팅 실패한다면 빈배열을 리턴한다.
            for attributedString in providers as? [NSAttributedString] ?? [] {
                self.addLabel(with: attributedString, centeredAt: dropPoint)
            }
        }
    }
    
    //이모티콘 리스트에서 이미지 뷰로 드랍하면 해당 자리에 UILabel로 해당 이모티콘을 추가한다.
    func addLabel(with attributedString: NSAttributedString, centeredAt point: CGPoint) {
        let label = UILabel()
        label.backgroundColor = .clear
        label.attributedText = attributedString
        label.sizeToFit()
        label.center = point
        addSubview(label)
    }

    //backgroundImage의 값이 바뀌면 호출 되는 Computed Property를 넣는다. 이미지를 그리도록 setNeedsDisplay() 메소드를 호출한다.
    var backgroundImage: UIImage? { didSet{ setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        //backgroundImage를 뷰 경계에 맞춰 그린다.
        backgroundImage?.draw(in: bounds)
    }
}
