//
//  EmojiArtDocumentTableViewController.swift
//  EmojiArt
//
//  Created by Soojung Shin on 2020/01/02.
//  Copyright © 2020 Soojung Shin. All rights reserved.
//

import UIKit

class EmojiArtDocumentTableViewController: UITableViewController {
    
    //테이블 뷰의 모델로 사용할 변수
    var emojiArtDocuments = ["one", "two", "three"]
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //splitView에서 왼쪽 뷰가 오른쪽 뷰 위에 올라오도록 한다. 오른쪽 뷰는 부분적으로 보이게 된다. 왼쪽 뷰는 스와이프로 보이고, 없앨 수 있다.
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
        
    }

    // MARK: - Table view data source

    //테이블 뷰의 섹션 개수를 정하는 메소드
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    //테이블 뷰의 섹션에 따른 행의 개수를 정하는 메소드. 여기서는 섹션이 1개 밖에 없기 때문에 섹션은 고려하지 않았다.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emojiArtDocuments.count
    }

    //셀을 설정해준다. 이때 이미 만들어진 재사용가능한 셀이 있다면 해당 셀을 가져오고, 없다면 프로토타입에서 identifier를 찾아 복사해 가져온다.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
        
        //basic style로 설정했기때문에 기본으로 옵셔널 타입의 textLabel이 하나 들어가있다.
        //섹션이 1개이기 때문에 indexPath에서는 row만 보고 가져오면 된다.
        cell.textLabel?.text = emojiArtDocuments[indexPath.row]
        return cell
    }
    
    //오른쪽 상단의 바 버튼을 누르면 emoji art document를 하나 추가한다.
    @IBAction func newEmojiArt(_ sender: UIBarButtonItem) {
        //Utilities.swift의 madeUnique 메소드를 사용하여 새로 만든 파일의 이름이 중복되지 않도록 한다. (untitled, 1, 2, 3...)
        emojiArtDocuments += ["untitled".madeUnique(withRespectTo: emojiArtDocuments)]
        
        //모델이 업데이트 되었으니 반드시 테이블 뷰도 업데이트 해주어야 한다.
        tableView.reloadData()
    }
    
    /*
    //행을 edit(삭제, 추가...) 가능하게 할 것인지 결정하는 메소드. true/false. 기본값은 true이기 때문에 불가능하게 설정할 것이 아니라면 구현하지 않아도 된다.
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    //edit(삭제, 추가...)을 작업하는 메소드. 여기서 모델에 작업 해주고, 테이블 뷰의 행도 동기화해준다.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //스와이프 동작으로 행을 delete 할 수 있다.
        if editingStyle == .delete {
            emojiArtDocuments.remove(at: indexPath.row)
            //무조건 모델에 수정사항이 있다면 동기화해주어야 한다. 모델과 테이블 뷰 행의 갯수가 다르다면 에러가 날 수 있다.
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            //Document 추가 기능은 바 버튼 액션으로 처리해주었기 때문에 여기서는 생략하겠다.
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
