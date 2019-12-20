//
//  PlayingCardDeck.swift
//  PlayingCard
//
//  Created by Soojung Shin on 2019/12/20.
//  Copyright © 2019 Soojung Shin. All rights reserved.
//

import Foundation

struct PlayingCardDeck {
    private(set) var cards = [PlayingCard]()
    
    init() {
        for suit in PlayingCard.Suit.all {
            for rank in PlayingCard.Rank.all {
                cards.append(PlayingCard(suit: suit, rank: rank))
            }
        }
    }
    
    //덱에서 랜덤으로 카드를 뽑는 동작
    //구조체이므로 자기자신의 변수를 변경하는 함수라면 mutating 표시를 해주어야한다.
    mutating func draw() -> PlayingCard? {
        if cards.count > 0 {
            return cards.remove(at: cards.count.arc4random)
        } else {
            return nil
        }
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
