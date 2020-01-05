//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by Soojung Shin on 2020/01/01.
//  Copyright © 2020 Soojung Shin. All rights reserved.
//

import UIKit

//UILabel에서 정보를 가져와 모델에 저장한다. UI와 관련된 extension이기 때문에 ViewController에 작성하였다.
extension EmojiArt.EmojiInfo {
    init?(label: UILabel) {
        if let attributedText = label.attributedText, let font = attributedText.font {
            x = Int(label.center.x)
            y = Int(label.center.y)
            text = attributedText.string
            size = Int(font.pointSize)
        } else {
            return nil
        }
    }
}


class EmojiArtViewController: UIViewController, UIDropInteractionDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    // MARK: - Model
    
    var emojiArt: EmojiArt? {
        //모델에 computed property를 사용하는 이유는 UI와 항상 동기화시키기 위함이다.
        get {
            if let url = emojiArtBackgroundImage.url {
                //emojiArtView의 subviews에 있는 UILabel들을 가져와 EmojiInfo를 만든다.
                let emojis = emojiArtView.subviews.compactMap { $0 as? UILabel }.compactMap { EmojiArt.EmojiInfo(label: $0) }
                return EmojiArt(url: url, emojis: emojis)
            }
            return nil
        }
        set {
            //새로운 모델로 지정되었기 때문에 현재 뷰를 초기화한다.
            emojiArtBackgroundImage = (nil, nil)
            emojiArtView.subviews.compactMap { $0 as? UILabel }.forEach { $0.removeFromSuperview() }
            
            //새로 설정된 모델 안의 값으로 UI를 설정한다.
            if let url = newValue?.url {
                imageFetcher = ImageFetcher(fetch: url) { (url, image) in
                    DispatchQueue.main.async {
                        self.emojiArtBackgroundImage = (url, image)
                        newValue?.emojis.forEach {
                            let attributedText = $0.text.attributedString(withTextStyle: .body, ofSize: CGFloat($0.size))
                            self.emojiArtView.addLabel(with: attributedText, centeredAt: CGPoint(x: $0.x, y: $0.y))
                        }
                    }
                }
            }
        }
    }
    
    //save 버튼을 누르면 해당 EmojiArt 모델을 JSON 파일 형식으로 Document Directory에 저장한다.
    @IBAction func save(_ sender: UIBarButtonItem) {
        if let json = emojiArt?.json {
            //파일을 저장할 때는 샌드박스 디렉토리 위치를 확인해야 한다. FileManager를 이용해 Document Directory의 URL을 가져온다.
            if let url = try? FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("Untitled.json") {
                do {
                    try json.write(to: url)
                    print ("saved successfully")
                } catch let error {
                    print ("couldn't save \(error)")
                }
            }
        }
    }
    
    
    //저장되어 있는 JSON 형태의 파일을 불러온다.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //샌드박스 디렉토리 위치를 확인해야 한다. FileManager를 이용해 Document Directory의 URL을 가져온다.
        if let url = try? FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
        ).appendingPathComponent("Untitled.json") {
            if let jsonData = try? Data(contentsOf: url) {
                emojiArt = EmojiArt(json: jsonData)
            }
        }
    }
    
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
    
    //배경 이미지의 URL을 저장하기 위한 변수
    private var _emojiArtBackgroundImageURL: URL?
    
    var emojiArtBackgroundImage: (url: URL?, image: UIImage?) {
        get {
            return (_emojiArtBackgroundImageURL, emojiArtView.backgroundImage)
        }
        set {
            _emojiArtBackgroundImageURL = newValue.url
            scrollView.zoomScale = 1.0
            emojiArtView.backgroundImage = newValue.image
            let size = newValue.image?.size ?? CGSize.zero
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
    
    //현재 이모티콘을 추가하고있는지 나타낸다.(textfield가 나타나있는지)
    private var addingEmoji = false
    
    @IBAction func addEmoji(_ sender: UIButton) {
        addingEmoji = true
        //0번 섹션에 버튼 셀과 텍스트필드 셀을 번갈아서 나타낼 것이기 때문에 섹션을 reload한다.
        emojiCollectionView.reloadSections(IndexSet(integer: 0))
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
            case 0: return 1
            case 1: return emojis.count
            default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //섹션이 1일 때
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
            if let emojiCell = cell as? EmojiCollectionViewCell {
                let text = NSAttributedString(string: emojis[indexPath.item], attributes: [.font: font])
                emojiCell.label.attributedText = text
            }
            return cell
        } else {
            //섹션이 0일 때
            if addingEmoji {
                //이모티콘을 추가하고 있는 중이라면 textField 셀을 반환한다.
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiInputCell", for: indexPath)
                if let inputCell = cell as? TextFieldCollectionViewCell {
                    inputCell.resignationHandler = { [weak self, unowned inputCell] in
                        //클로저에서 memory cycle이 발생하기 때문에 self를 weak로, inputCell은 반드시 존재하는 상황이기 때문에 unowned로 선언해준다.
                        if let text = inputCell.textField.text {
                            //textField에 있는 text를 배열로 만들어서 emojis의 앞에 넣는다.
                            //uniquified로 배열의 중복된 값을 제거한다.
                            self?.emojis = (text.map{ String($0) } + self!.emojis).uniquified
                        }
                        self?.addingEmoji = false
                        self?.emojiCollectionView.reloadData()
                    }
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddEmojiButtonCell", for: indexPath)
                return cell
            }
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //EmojiInputCell(textField가 있는 셀)이라면 셀의 가로 사이즈를 더 크게 한다.
        if indexPath.section == 0 && addingEmoji {
            return CGSize(width: 300, height: 80)
        }
        return CGSize(width: 80, height: 80)
    }
    
    // MARK: - UICollectionViewDelegate
    
    //셀을 화면에 표시하기 전에 호출되는 메소드.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //TextFieldCollectionViewCell이라면 내부의 textField가 first responder가 되도록 한다.
        if let inputCell = cell as? TextFieldCollectionViewCell {
            inputCell.textField.becomeFirstResponder()
        }
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
        //addingEmoji 상태일 때는 드래그가 불가능하도록 한다.
        if !addingEmoji, let attributedString = (emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.label.attributedText {
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
        //collectionView의 섹션 1에만 아이템을 드롭할 수 있게 한다.
        if let indexPath = destinationIndexPath, indexPath.section == 1 {
            //드래그가 컬렉션 뷰 안에서 시작됐는지 확인하고, 안에서 시작됐다면 .move, 밖에서 시작됐다면 .copy 한다.
            let itSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
            return UICollectionViewDropProposal(operation: itSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .cancel)
        }
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
                self.emojiArtBackgroundImage = (url, image)
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
