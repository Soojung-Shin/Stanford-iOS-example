//
//  ConcentrationThemeChooserViewController.swift
//  ConcentrationGame
//
//  Created by Soojung Shin on 2019/12/27.
//  Copyright © 2019 Soojung Shin. All rights reserved.
//

import UIKit

class ConcentrationThemeChooserViewController: UIViewController, UISplitViewControllerDelegate {

    let themes = [
        "Sports": "⚽️🏀🏈⚾️🎾🏐🏉🎱🏓⛷🎳⛳️",
        "Animals": "🐶🦆🐹🐸🐘🦍🐓🐩🐦🦋🐙🐏",
        "Faces": "😀😌😎🤓😠😤😭😰😱😳😜😇"
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        splitViewController?.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "Choose Theme", let cvc = segue.destination as? ConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                cvc.theme = theme
                lastSeguedToConcentrationViewController = cvc
            }
        }
    }
    
    //앱 실행 시작 화면이 디테일뷰가 아닌 마스터뷰로 설정되도록하는 메소드.
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        //게임 뷰 컨트롤러의 theme 변수가 한 번도 설정되지 않았다면 마스터 뷰가 앞으로 오도록 한다.(return true)
        if let cvc = secondaryViewController as? ConcentrationViewController {
            return cvc.theme == nil
        }
        return false
    }
    
    private var splitViewDetailConcentrationViewController: ConcentrationViewController? {
        return splitViewController?.viewControllers.last as? ConcentrationViewController
    }
    
    //마지막으로 segue된 게임 화면 컨트롤러를 저장한다. 네비게이션 뷰의 스택에서 pop 되더라도 힙에 해당 컨트롤러의 정보가 계속 유지되도록 한다.
    private var lastSeguedToConcentrationViewController: ConcentrationViewController?
    
    
    //테마를 바꿔도 게임이 매번 새로 시작되지 않게 하는 메소드.
    @IBAction func changeTheme(_ sender: UIButton) {
        if let cvc = splitViewDetailConcentrationViewController {
            //스플릿뷰인 경우, 디테일뷰 컨트롤러를 찾아 디테일뷰의 테마만 변경한다.
            if let themeName = sender.currentTitle, let theme = themes[themeName] {
                cvc.theme = theme
            }
        } else if let cvc = lastSeguedToConcentrationViewController {
            //스플릿뷰의 디테일뷰 컨트롤러를 찾지 못하면 마지막으로 segue되었던 뷰 컨트롤러를 찾아 테마를 지정하고, 네비게이션 화면에 push한다.
            if let themeName = sender.currentTitle, let theme = themes[themeName] {
                cvc.theme = theme
            }
            navigationController?.pushViewController(cvc, animated: true)
        } else {
            //스플릿뷰와 마지막으로 segue된 화면을 찾지 못했다면(한번도 segue되지 않은 상태라면), segue를 실행한다. 새로운 mvc 인스턴스가 생성된다.
            performSegue(withIdentifier: "Choose Theme", sender: sender)
        }
    }
}
