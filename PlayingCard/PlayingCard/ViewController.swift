//
//  ViewController.swift
//  PlayingCard
//
//  Created by Soojung Shin on 2019/12/20.
//  Copyright © 2019 Soojung Shin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var deck = PlayingCardDeck()

    //PlayingCardView에 대한 제스처를 추가해주기 위해서 아울렛을 만든다.
    @IBOutlet var playingCardView: PlayingCardView! {
        didSet {
            //왼쪽, 오른쪽 swipe 제스처로 다음 카드를 뽑는다. 이때 model과 view가 연결되어야 하기 때문에 controller에서 처리해주어야 한다. 따라서 타겟은 controller인 self가 된다.
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
            swipe.direction = [.left, .right]
            //해당 뷰가 swipe 제스처를 인식할 수 있도록 추가한다.
            playingCardView.addGestureRecognizer(swipe)
        }
    }
    
    //제스처 매커니즘이 objective-c로 만들어졌기 때문에 제스처의 action이 될 메소드는 @objc 키워드로 표시해주어야 한다.
    @objc func nextCard() {
        if let nextCard = deck.draw() {
            playingCardView.suit = nextCard.suit.rawValue
            playingCardView.rank = nextCard.rank.order
        }
    }
    
    //카드를 탭하면 뒤집는 동작을 하는 액션. 제스처를 스토리보드에서 직접 추가해 이렇게 action을 줄 수도 있다.
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        //UIGestureRecognizer의 state를 switch로 받아와 각각의 경우에 맞게 처리한다.
        switch sender.state {
        case .ended:
            playingCardView.isFaceUp = !playingCardView.isFaceUp
        default: break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


}

