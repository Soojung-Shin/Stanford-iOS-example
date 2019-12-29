//
//  CardBehavior.swift
//  PlayingCard
//
//  Created by Soojung Shin on 2019/12/29.
//  Copyright © 2019 Soojung Shin. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = 1.0
        behavior.resistance = 0
        return behavior
    }()

    func push(_ item: UIDynamicItem) {
        let pushBehavior = UIPushBehavior(items: [item], mode: .instantaneous)
        pushBehavior.angle = CGFloat(Int(2 * CGFloat.pi).arc4random) + CGFloat(drand48())
        pushBehavior.magnitude = 1 + CGFloat(drand48())
        //pushBehavior는 일회성 애니메이션이기 때문에 사용되면 삭제해주는 것이 좋다. 액션에서 처리해주는데, 이때 애니메이터와 behavior 클로져가 서로를 가리키고 있기 때문에 메모리 사이클이 발생한다. unowned와 weak를 사용해 클로져에 변수를 선언하여 힙에 존재하지않도록 설정하여 해결할 수 있다.
        pushBehavior.action = { [unowned pushBehavior, weak self] in
            self?.removeChildBehavior(pushBehavior)
        }
        addChildBehavior(pushBehavior)
    }
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
