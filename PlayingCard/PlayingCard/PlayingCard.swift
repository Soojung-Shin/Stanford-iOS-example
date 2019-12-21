//
//  PlayingCard.swift
//  PlayingCard
//
//  Created by Soojung Shin on 2019/12/20.
//  Copyright © 2019 Soojung Shin. All rights reserved.
//

import Foundation

struct PlayingCard: CustomStringConvertible {
    //CustomStringConvertible 프로토콜을 이용해 print()를 이용할 때, 설정해둔 형식으로 출력할 수 있다.
    var description: String { return "\(suit) \(rank)" }

    var suit: Suit
    var rank: Rank
    
    enum Suit: String, CustomStringConvertible {
        case spades = "♠️"
        case hearts = "♥️"
        case diamonds = "♦️"
        case clubs = "♣️"
        
        //모든 값을 가지고 올 것이기 때문에 static 변수로 선언한다.
        //배열에서 타입 지정 안해줬을 때, 맨 앞 요소만 타입을 적어주면 뒤에는 생략해도 된다.
        static var all = [Suit.spades, .hearts, .diamonds, .clubs]
        
        var description: String { return rawValue }
    }
    
    enum Rank: CustomStringConvertible {
        case ace
        case face(String)
        case numeric(Int)
        
        var order: Int {
            //switch문을 이용한 패턴 매칭
            switch self {
                case .ace: return 1
                case .numeric(let pips): return pips
                case .face(let kind) where kind == "J": return 11
                case .face(let kind) where kind == "Q": return 12
                case .face(let kind) where kind == "K": return 13
                //where는 가능한 모든 경우의 수를 따지지 않기 때문에 default를 꼭 적어주어야 한다.
                default: return 0
            }
        }
        
        static var all: [Rank] {
            var allRanks: [Rank] = [.ace]
            //다른 열거형에서 해당 케이스를 가지고 있을 수 있기 때문에 타입 지정 필수. 아니면 값 넣을 때 Rank.ace로 넣으면 타입 추론이 가능해진다.
            for pips in 2...10 {
                allRanks.append(.numeric(pips))
            }
            allRanks += [Rank.face("J"), .face("Q"), .face("K")]
            return allRanks
        }
        
        var description: String {
            switch self {
            case .ace: return "a"
            case .numeric(let pips): return String(pips)
            case .face(let kind): return kind
            }
        }
    }
}
