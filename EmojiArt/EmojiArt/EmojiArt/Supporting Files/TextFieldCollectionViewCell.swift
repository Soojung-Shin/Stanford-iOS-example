//
//  TextFieldCollectionViewCell.swift
//  EmojiArt
//
//  Created by Soojung Shin on 2020/01/03.
//  Copyright © 2020 Soojung Shin. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
            textField.clearsOnBeginEditing = true
        }
    }
    
    //컬렉션 뷰에게 메세지를 받기 위해 사용할 메소드.
    var resignationHandler: (() -> Void)?
    
    //textField의 editing이 끝나면 호출되는 메소드.
    func textFieldDidEndEditing(_ textField: UITextField) {
        //컬렉션 뷰에서 지정한 resignationHandler 클로저 함수를 실행한다.
        resignationHandler?()
    }
    
    //키보드의 리턴 키를 누르면 호출되는 메소드. textField의 firstResponder 상태를 다시 반환한다.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
