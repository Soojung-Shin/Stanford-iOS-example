//
//  ViewController.swift
//  PlayingCard
//
//  Created by Soojung Shin on 2019/12/20.
//  Copyright © 2019 Soojung Shin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet var cardViews: [PlayingCardView]!
    
    var deck = PlayingCardDeck()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count + 1) / 2) {
            if let card = deck.draw() { cards += [card, card] }
        }
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.suit = card.suit.rawValue
            cardView.rank = card.rank.order
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
        }
    }

    //PlayingCardView에 대한 제스처를 추가해주기 위해서 아울렛을 만든다.
    @IBOutlet var playingCardView: PlayingCardView! {
        didSet {
            //왼쪽, 오른쪽 swipe 제스처로 다음 카드를 뽑는다. 이때 model과 view가 연결되어야 하기 때문에 controller에서 처리해주어야 한다. 따라서 타겟은 controller인 self가 된다.
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
            swipe.direction = [.left, .right]
            //해당 뷰가 swipe 제스처를 인식할 수 있도록 추가한다.
            playingCardView.addGestureRecognizer(swipe)
            
            //카드가 K, Q, J 일 때, pinch 제스처를 통해 카드 중앙의 이미지 크기를 조절한다. 이때 model과의 연결이 필요없는 view 자체의 동작이기 때문에 target은 해당 view가 된다.
            let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(playingCardView.adjustFaceCardScale(byHandlingGestureRecognizedBy:)))
            playingCardView.addGestureRecognizer(pinch)
        }
    }
    
    //제스처 매커니즘이 objective-c로 만들어졌기 때문에 제스처의 action이 될 메소드는 @objc 키워드로 표시해주어야 한다.
    @objc func nextCard() {
        if let nextCard = deck.draw() {
            playingCardView.suit = nextCard.suit.rawValue
            playingCardView.rank = nextCard.rank.order
        }
    }
    
    //카드를 탭하면 뒤집는 동작을 하는 액션.
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        //UIGestureRecognizer의 state를 switch로 받아와 각각의 경우에 맞게 처리한다.
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView {
                //카드를 눌렀을 때 세로축을 기준으로 뒤집히는 애니메이션
                UIView.transition(
                    with: chosenCardView,
                    duration: 0.6,
                    options: [.transitionFlipFromLeft],
                    animations: { chosenCardView.isFaceUp = !chosenCardView.isFaceUp },
                    completion: { position in
                        var faceUpCardViews: [PlayingCardView] {
                            return self.cardViews.filter { $0.isFaceUp }
                        }
                        
                        //뒤집힌 카드가 두장이면 뒷면이 오도록 뒤집는다.
                        if faceUpCardViews.count == 2 {
                            faceUpCardViews.forEach { cardView in
                                UIView.transition(
                                    with: cardView,
                                    duration: 0.8,
                                    options: [.transitionFlipFromLeft],
                                    animations: { cardView.isFaceUp = false }
                                )
                            }
                        }
                    }
                )
            }
        default: break
        }
    }
}
