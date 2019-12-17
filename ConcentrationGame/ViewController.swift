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
    private var emojis = [ "😈", "👻", "🤡", "🍭", "🍫", "😺", "🎃", "🍬" ]
    private var emojiChoices: [Int : String] = [:]

    
    private func setEmoji(for card: Card) -> String {
        if emojiChoices[card.identifier] == nil, emojis.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(emojis.count)))
            let emoji = emojis.remove(at: randomIndex)
            emojiChoices[card.identifier] = emoji
        }
        
        return emojiChoices[card.identifier] ?? "?"
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
        emojis = [ "😈", "👻", "🤡", "🍭", "🍫", "😺", "🎃", "🍬" ]
        emojiChoices = [Int : String]()

        updateViewFromModel()
        sender.isHidden = true
    }
}

