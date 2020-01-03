//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by Soojung Shin on 2020/01/01.
//  Copyright © 2020 Soojung Shin. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController, UIDropInteractionDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    // MARK: - Storyboard
    
    //drop zone 뷰를 연결하고, drop 인터렉션을 추가한다.
    @IBOutlet weak var dropZone: UIView! {
        didSet {
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
            
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.addSubview(emojiArtView)
        }
    }
    
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewWidth.constant = scrollView.contentSize.width
        scrollViewHeight.constant = scrollView.contentSize.height
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiArtView
    }
    
    var emojiArtBackgroundImage: UIImage? {
        get {
            return emojiArtView.backgroundImage
        }
        set {
            scrollView.zoomScale = 1.0
            emojiArtView.backgroundImage = newValue
            let size = newValue?.size ?? CGSize.zero
            emojiArtView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView.contentSize = size
            scrollViewWidth.constant = size.width
            scrollViewHeight.constant = size.height
            if let dropZone = self.dropZone, size.width > 0, size.height > 0 {
                scrollView.zoomScale = max(dropZone.bounds.size.width / size.width, dropZone.bounds.size.height / size.height)
            }
        }
    }
    
    var emojiArtView = EmojiArtView()

    // MARK: - Emoji Collection View
    
    var emojis = "😀😇😌😍🥰😘😎🤓😈🌛🌞⭐️🌎🍎🍉🍒🥑⚽️".map { String($0) }
    
    @IBOutlet weak var emojiCollectionView: UICollectionView! {
        didSet {
            emojiCollectionView.dataSource = self
            emojiCollectionView.delegate = self
            emojiCollectionView.dragDelegate = self
            emojiCollectionView.dropDelegate = self
        }
    }
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body)).withSize(64.0)
    }

    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        if let emojiCell = cell as? EmojiCollectionViewCell {
            let text = NSAttributedString(string: emojis[indexPath.item], attributes: [.font: font])
            emojiCell.label.attributedText = text
        }
        return cell
    }
    
    // MARK: - UICollectionViewDragDelegate

    //드래그를 시작할 때 호출되는 메소드. 드래그할 아이템을 지정해준다.
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        //드래그를 시작할 때 session에 localContext를 알려주어 drop할 때 알 수 있게 한다.
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    //드래그 하는 도중에 다른 셀들을 탭하면 드래그 아이템 배열에 아이템을 추가하는 메소드. 드래그 아이템에 탭한 아이템이 추가된다.
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }

    //indexPath를 이용해 long press된 cell 안에 있는 label의 attributedString을 가져오고, 그 값을 dragItem 만들어 배열로 리턴한다.
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let attributedString = (emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.label.attributedText {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            //만약 앱 내에서 앱 내로 드래그 되는 경우, itemProvider와 관련된 복잡한 메소드를 사용하지 않고, 지역화된 객체를 바로 잡을 수 있게 하여 간단하게 구현할 수 있다.
            dragItem.localObject = attributedString
            return [dragItem]
        } else {
            return []
        }
    }
    
    // MARK: - UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        //드래그가 컬렉션 뷰 안에서 시작됐는지 확인하고, 안에서 시작됐다면 .move, 밖에서 시작됐다면 .copy 한다.
        let itSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: itSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        //destinationIndexPath가 없다면(컬렉션 뷰의 셀이 아닌 다른 곳에 두었다면) 아이템이 0, 섹션이 0인 IndexPath를 갖는다.
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        //드래그 중인 아이템이 여러개 일 수도 있으니 for문으로 처리한다.
        for item in coordinator.items {
            //드래그가 컬렉션 뷰에서 시작됐다면 sourceIndexPath를 받아온다.
            if let sourceIndexPath = item.sourceIndexPath {
                if let attributedString = item.dragItem.localObject as? NSAttributedString {
                    
                    //뷰와 모델은 항상 동기화 되어야한다. 클로져 안에 있는 작업을 한번에 처리해준다.
                    collectionView.performBatchUpdates({
                        //모델에서 드래그한 아이템을 삭제하고, destination 인덱스에 추가한다.
                        emojis.remove(at: sourceIndexPath.item)
                        emojis.insert(attributedString.string, at: destinationIndexPath.item)
                        
                        //컬렉션 뷰에서 드래그한 아이템을 삭제하고, destination 인덱스에 추가한다.
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    
                    //드랍 애니메이션을 추가한다. 손가락을 떼면 지정된 toItemAt으로 드래그 아이템이 자연스럽게 들어간다.
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                //외부 앱에서 드래그 아이템을 가지고오는 경우
                let placeholderContext = coordinator.drop(
                    item.dragItem,
                    to: UICollectionViewDropPlaceholder(
                        insertionIndexPath: destinationIndexPath,
                        reuseIdentifier: "DropPlaceholderCell"
                    )
                )
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, errror) in
                    DispatchQueue.main.async {
                        //placeholder를 변경해야하기 때문에 main queue에서 작업한다.
                        if let attributedString = provider as? NSAttributedString {
                            //attributedString을 성공적으로 가져왔다면, placeholderContext에게 셀을 교체하라고 한다.
                            placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                self.emojis.insert(attributedString.string, at: insertionIndexPath.item)
                                //이때 주의할 점은 destinationIndexPath가 아닌 insertIndexPath를 사용해야한다는 것이다. 아이템을 로드하는 시간이 동안 다른 동작으로 인해 컬렉션 뷰나 모델이 변경될 수 있기 때문이다.
                            })
                        } else {
                            //에러가 나서 스트링을 가지고오지 못한 경우 placeholder를 삭제한다.
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - UIDropInteractionDelegate
    
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
                self.emojiArtBackgroundImage = image
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
}
