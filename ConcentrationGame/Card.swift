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
    let identifier: Int
    
    static var identifierFactory = 0
    
    static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    //카드에 대한 정보를 Card 구조체에서 관리하게 된다. 구조체는 모든 인자를 초기화할 수 있는 공짜 init 함수를 가진다. 하지만 이미 초기화되어있는 프로퍼티도 다시 초기화하는 번거로움이 생기기때문에 새로운 init을 재정의 해준다.
    init() {
        //self는 해당 구조체가 가지고있는 identifier를 가리키기 위해 사용했다.
        self.identifier = Card.getUniqueIdentifier()
    }
}
