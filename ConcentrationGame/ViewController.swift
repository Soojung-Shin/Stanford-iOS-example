//
//  ViewController.swift
//  ConcentrationGame
//
//  Created by Soojung Shin on 2019/12/13.
//  Copyright © 2019 Soojung Shin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var game = Concentration(numberOfCardPair: (cardButtons.count + 1) / 2)
    
    var flipCount = 0 {
        didSet {
            flipCountLabel.text = "\(flipCount)"
        }
    }
        
    @IBOutlet var flipCountLabel: UILabel!
    @IBOutlet var cardButtons: [UIButton]!
    @IBOutlet var resetButton: UIButton!
    
    
    override func viewDidLoad() {
        updateViewFromModel()
        
        //처음 시작할 때는 reset 버튼이 보이지 않게 설정한다.
        resetButton.isHidden = true
    }
    
    
    @IBAction func clickCard(_ sender: UIButton) {
        if let index = cardButtons.firstIndex(of: sender), sender.backgroundColor == .orange {
            flipCount += 1
            game.chooseCard(of: index)
            updateViewFromModel()
        }
        
        if game.isAllMatched() {
            resetButton.isHidden = false
        }
    }

    
    var emojis = [ "😈", "👻", "🤡", "🍭", "🍫", "😺", "🎃", "🍬" ]
    var emojiChoices: [Int : String] = [:]

    
    func setEmoji(for card: Card) -> String {
        if emojiChoices[card.identifier] == nil, emojis.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(emojis.count)))
            let emoji = emojis.remove(at: randomIndex)
            emojiChoices[card.identifier] = emoji
        }
        
        return emojiChoices[card.identifier] ?? "?"
    }
    
    
    func updateViewFromModel() {
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
    @IBAction func clickResetButton(_ sender: UIButton) {
        //모델을 초기화한다.
        game = Concentration(numberOfCardPair: (cardButtons.count + 1) / 2)
        
        flipCount = 0
        emojis = [ "😈", "👻", "🤡", "🍭", "🍫", "😺", "🎃", "🍬" ]
        emojiChoices = [Int : String]()

        updateViewFromModel()
        sender.isHidden = true
    }
}

