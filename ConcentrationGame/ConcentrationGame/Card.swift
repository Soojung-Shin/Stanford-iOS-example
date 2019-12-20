//
//  Card.swift
//  ConcentrationGame
//
//  Created by Soojung Shin on 2019/12/13.
//  Copyright © 2019 Soojung Shin. All rights reserved.
//

import Foundation

struct Card {
    var isFacedUp = false
    var isMatched = false
    //Equatable 프로토콜을 구현하였기 때문에 이제 Card 구조체 밖에서 identifier를 찾을 필요가 없어졌다. private로 변경한다.
    private let identifier: Int
    
    //해당 구조체 밖에서 사용하지 않으므로 private 처리
    private static var identifierFactory = 0
    
    private static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    //카드에 대한 정보를 Card 구조체에서 관리하게 된다. 구조체는 모든 인자를 초기화할 수 있는 공짜 init 함수를 가진다. 하지만 이미 초기화되어있는 프로퍼티도 다시 초기화하는 번거로움이 생기기때문에 새로운 init을 재정의 해준다.
    init() {
        //self는 해당 구조체가 가지고있는 identifier를 가리키기 위해 사용했다.
        self.identifier = Card.getUniqueIdentifier()
    }
}

//Card가 Hashable 프로토콜을 상속받는 extension을 만든다.
//Hashable은 Equatable을 상속받고 있기 때문에 Equatable 프로토콜의 내용도 함께 구현해준다.
extension Card: Hashable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
