//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by Soojung Shin on 2020/01/01.
//  Copyright © 2020 Soojung Shin. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController, UIDropInteractionDelegate {
    
    //drop zone 뷰를 연결하고, drop 인터렉션을 추가한다.
    @IBOutlet weak var dropZone: UIView! {
        didSet {
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        //session에 NSURL, UIImage를 가지고 올 수 있는지 확인한다.
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        //외부에서 이미지를 가지고오는 것이기 때문에 복사를 사용한다.
        return UIDropProposal(operation: .copy)
    }
    
    var imageFetcher: ImageFetcher!
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        imageFetcher = ImageFetcher() { (url, image) in
            DispatchQueue.main.async {
                self.emojiArtView.backgroundImage = image
            }
        }
        
        //session에서 객체를 불러온 후 imageFetcher에 fetch한다.
        session.loadObjects(ofClass: NSURL.self) { nsurls in
            //여러개를 드래그 할 수 있기 때문에 그 중 첫 번째 URL을 선택한다.
            if let url = nsurls.first as? URL {
                self.imageFetcher.fetch(url)
            }
        }
        
        session.loadObjects(ofClass: UIImage.self) { images in
            //여러개를 드래그 할 수 있기 때문에 그 중 첫 번째 이미지를 선택한다.
            if let image = images.first as? UIImage {
                //imageFetcher의 backup 이미지에 해당 이미지를 저장한다.
                self.imageFetcher.backup = image
            }
        }
    }
    
    @IBOutlet weak var emojiArtView: EmojiArtView!
}
