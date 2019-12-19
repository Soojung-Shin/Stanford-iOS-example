//
//  ViewController.swift
//  ConcentrationGame
//
//  Created by Soojung Shin on 2019/12/13.
//  Copyright © 2019 Soojung Shin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //외부에서 사용하지않는 변수이기 때문에 private로 설정한다.
    private lazy var game = Concentration(numberOfCardPair: (cardButtons.count + 1) / 2)
    
    //몇 번이나 뒤집었는지에 대해서 외부에서 설정할 수 없도록 private(set)으로 설정한다.
    private(set) var flipCount = 0 {
        didSet {
            flipCountLabel.text = "\(flipCount)"
        }
    }
        
    //UI 내부의 구현 방식이기 때문에 IBOutlet도 모두 private로 설정한다.
    @IBOutlet private var flipCountLabel: UILabel!
    @IBOutlet private var cardButtons: [UIButton]!
    @IBOutlet private var resetButton: UIButton!
    
    
    override func viewDidLoad() {
        updateViewFromModel()
        
        //처음 시작할 때는 reset 버튼이 보이지 않게 설정한다.
        resetButton.isHidden = true
    }
    
    //UI 내부의 구현 방식이기 때문에 IBAction도 모두 private로 설정한다.
    @IBAction private func clickCard(_ sender: UIButton) {
        if let index = cardButtons.firstIndex(of: sender), sender.backgroundColor == .orange {
            flipCount += 1
            game.chooseCard(of: index)
            updateViewFromModel()
        }
        
        if game.isAllMatched() {
            resetButton.isHidden = false
        }
    }

    //아래 모든 변수와 함수도 외부에서의 접근을 private로 제한한다.
    //private var emojis = [ "😈", "👻", "🤡", "🍭", "🍫", "😺", "🎃", "🍬" ]
    //emojis를 문자열로 변경한다.
    private var emojis = "😈👻🤡🍭🍫😺🎃🍬"

    
    //Dictionary의 키 값은 항상 Hashable 해야한다. Card에 Hashable 프로토콜을 추가했기 때문에 Dictionary의 키로 사용할 수 있게 된다.
    private var emojiChoices: [Card : String] = [:]

    
    private func setEmoji(for card: Card) -> String {
        if emojiChoices[card] == nil, emojis.count > 0 {

            //Int extension으로 랜덤값을 가져오는 프로퍼티를 추가했기 때문에 더이상 아래 코드를 이용하지 않는다.
            //let randomIndex = Int(arc4random_uniform(UInt32(emojis.count)))
            //let emoji = emojis.remove(at: emojis.count.arc4random)
            //emojiChoices[card] = emoji
            
            //emojis를 String으로 변경했기 때문에 정수형 인덱스로 접근할 수 없다. String.Index 타입으로 변경한다.
            let randomStringIndex = emojis.index(emojis.startIndex, offsetBy: emojis.count.arc4random)
            emojiChoices[card] = String(emojis.remove(at: randomStringIndex))
        }

        return emojiChoices[card] ?? "?"
    }
    
    
    private func updateViewFromModel() {
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game.cards[index]
            
            if card.isFacedUp {
                button.setTitle(setEmoji(for: card), for: .normal)
                button.backgroundColor = .white
            } else {
                button.setTitle("", for: .normal)
                button.backgroundColor = card.isMatched ? .clear : .orange
            }
        }
    }
    
    
    //게임을 reset 하는 버튼 클릭 액션
    //UI 내부의 구현 방식이기 때문에 IBOutlet도 모두 private로 설정한다.
    @IBAction private func clickResetButton(_ sender: UIButton) {
        //모델을 초기화한다.
        game = Concentration(numberOfCardPair: (cardButtons.count + 1) / 2)
        
        flipCount = 0
        emojis = "😈👻🤡🍭🍫😺🎃🍬"
        emojiChoices = [Card : String]()

        updateViewFromModel()
        sender.isHidden = true
    }
}

//extension을 사용해 현재 존재하고있는 데이터 구조를 확장시킬 수 있다. class/struct/enum 등에 method와 properties를 추가할 수 있다.
//extension에는 저장공간을 할당할 수 없기 때문에, let, var와 같은 저장 프로퍼티를 사용할 수 없다.
//확장을 이용할 때는 연관성이 적은 코드들을 작성하는 것을 지양하도록 하자!
//Int 타입에 새로운 computed property를 추가함으로서 지저분하게 보일 수 있는 코드를 정리했다. Int.arc4random 형식으로 사용한다. (ex. 100.arc4random)
extension Int {
    var arc4random: Int {
        if self > 0 {   //여기서 self는 Int의 값을 의미한다.
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
