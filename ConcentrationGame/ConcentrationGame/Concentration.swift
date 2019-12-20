//
//  Concentration.swift
//  ConcentrationGame
//
//  Created by Soojung Shin on 2019/12/13.
//  Copyright © 2019 Soojung Shin. All rights reserved.
//

import Foundation

//클래스는 reference type이다. 클래스는 복사되지 않고, 해당 클래스를 가리키는 포인터를 전달하게 된다.
//반면 구조체는 value type이다. value type은 쓰기 시 복사하는 형태로 값을 복사한다.
//구조체는 기본적으로 자기 자신 내부에 있는 값을 변경할 수 없기 때문에 변경하고자 할 때는 mutating라고 표시해주어야 한다.
//class Concentration {
struct Concentration {
    
    //ViewController에서 카드들에 대한 정보를 봐야하기 때문에 get에 대한 접근은 public으로 놓지만, 카드들에 대한 정보를 할당하거나 수정하는 것은 이 cards의 일이기 때문에 private(set)으로 설정한다.
    //따라서 ViewController는 cards에 값을 할당할 수는 없지만 접근은 가능하다.
    private(set) var cards: [Card]
    
    init(numberOfCardPair: Int) {
        assert(numberOfCardPair > 0, "Concentration.init(numberOfCardPair: \(numberOfCardPair) 에러: 적어도 한 쌍 이상의 카드를 생성하여야 합니다.")
        cards = [Card]()
        for _ in 0 ..< numberOfCardPair {
            let card = Card()
            cards += [card, card]
        }
        shuffleCard()
    }
    
    //뒤집어져있는 카드의 인덱스, 한 장도 뒤집어져있지 않을 경우 nil을 갖는다.
    //Computed Property를 이용해서 값을 처리한다.
    //왜? 여기서 이 값에는 어떤 인덱스를 저장하는 것이 목적이 아니고, 어떤 카드가 뒤집혀있는지, 일치하지않는 카드는 다시 뒤집어 놓는 그 행위가 중요한 것이기 때문??
    //해당 정보를 다른 곳에서 접근할 필요가 없으므로 private로 지정한다.
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            /*
            //optional 변수는 처음 선언했을 때 기본값은 nil이다.
            var foundIndex: Int?
            
            //cards를 순회하면서 뒤집혀져있는(이모티콘이 보이는) 카드가 있다면 그 값을 foundIndex에 넣는다. 만약 이미 foundIndex에 값이 들어있는 상황에서 뒤집혀져있는 카드를 또 발견한다면 (두 장이 이미 뒤집혀져있는 상황) nil을 반환한다.
            for index in cards.indices {
                if cards[index].isFacedUp {
                    if foundIndex == nil {
                        foundIndex = index
                    } else {
                        return nil
                    }
                }
            }
            
            //한 장도 뒤집혀져있지 않은 상황이라면 foundIndex의 초기값인 nil을 반환하게 된다. 한 장이 뒤집혀져있는 상황이라면 foundIndex에 저장해두었던 index가 반환된다.
            return foundIndex
            */
            
            //closure를 사용해 위의 코드를 간단하게 처리한다.
            //Collection extension에서 만든 oneAndOnly 변수를 사용한다.
            return cards.indices.filter { cards[$0].isFacedUp }.oneAndOnly
        }
        
        //set은 newValue 값을 기본 인자로 갖는다. 선언해주지않으면 newValue라는 이름으로 인자를 사용할 수 있고, set(a), set(a, b) 등으로 이용할 수도 있다.
        set {
            //cards를 순회하면서 (여기서는 index값을 사용해야하기 때문에 cards.indecies를 설정해 index를 적용했다.)
            for index in cards.indices {
                //해당 index와 indexOfOneAndOnlyFaceUpCard에 설정하려고 하는 값을 비교해 같다면 true, 다르면 false로 설정한다.
                //즉, newValue 인덱스 값만 true로 놓고, 나머지는 모두 false로 설정한다. newValue 인덱스를 가진 카드만 이모티콘이 보이게 하고, 나머지는 모두 안보이도록 설정한다.
                cards[index].isFacedUp = (index == newValue)
            }
        }
    }
    
    //카드를 선택했을 때 처리
    //Concentration이 구조체이기 때문에 함수에서 자기 자신의 값을 변경하고자 할 때는 'mutating'을 추가해주어야 한다.
    mutating func chooseCard(of index: Int) {
        //assert 함수는 assert 내부의 값이 false일 때 오류를 발생시킨다. 협업을 하는 과정에서 내부 구조를 모르는 상태에서 존재하지 않는 값에 접근하면 에러를 발생할 것이고, 어떠한 이유에 대해선지 인지하기 힘든 경우가 발생할 수도 있다. 이를 방지하기 위해 사용한다.
        assert(cards.indices.contains(index), "Concentration.chooseCard(of: \(index)) 에러: 선택한 인덱스의 카드가 없습니다.")
        
        if !cards[index].isMatched {
            
            //카드 한 장이 이미 뒤집어져 있을 때
            //indexOfOneAndOnlyFaceUpCard의 get을 이용해 matchIndex를 구한다. 한 장이 뒤집혀있다면 그 인덱스값을 matchIndex에 저장할 것이고, 두 장이 뒤집혀있거나, 아무것도 뒤집혀있지 않은 경우 nil을 저장한다.
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                
                //카드 두 장의 identifier을 비교해서 같으면 isMatched를 true로 바꾼다.
                //if cards[index].identifier == cards[matchIndex].identifier {
                //Card에서 hashable 프로토콜을 구현하면서 equatable 프로토콜도 구현하였기 때문에 더이상 Concentration에서 identifier로 비교하지 않아도 된다.
                if cards[index] == cards[matchIndex] {
                    cards[index].isMatched = true
                    cards[matchIndex].isMatched = true
                }
                
                //두 번째 장을 뒤집는다.
                cards[index].isFacedUp = true
                
                //indexOfOneAndOnlyFaceUpCard에 computed property를 사용했기 때문에 더이상 해당 코드가 필요하지 않다.
                //indexOfOneAndOnlyFaceUpCard = nil
            } else {
                
                //indexOfOneAndOnlyFaceUpCard에 computed property를 사용했기 때문에 더이상 해당 코드가 필요하지 않다.
                //set을 이용해 해당 작업을 모두 처리해주었다.
                
                /*
                //뒤집힌 카드가 없을 때
                for index in cards.indices {
                    cards[index].isFacedUp = false
                }
                
                //선택된 카드를 뒤집고, 해당 카드의 인덱스를 저장한다.
                cards[index].isFacedUp = true
                */
                
                indexOfOneAndOnlyFaceUpCard = index
            }
        }
    }
    
    
    //카드의 위치를 랜덤하게 섞는 메서드
    //cards 배열에 카드를 다 추가하고 난 후 실행할 것
    mutating func shuffleCard() {
        cards.shuffle()
    }
    
    
    //모두 match 되었는지 확인하는 메서드
    func isAllMatched() -> Bool {
        for index in cards.indices {
            if !cards[index].isMatched {
                return false
            }
        }
        return true
    }
}


//Collection을 extension
//Collection으로 구현된 어떤 것(Array, String, Countable Range...)이든 해당 extension을 사용할 수 있다.
extension Collection {
    //해당 Collection의 내부의 값이 1개라면 그 값을, 아니면 nil을 리턴한다.
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}
