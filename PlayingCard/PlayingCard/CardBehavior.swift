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
    
    lazy var gravityBehavior: UIGravityBehavior = {
        let behavior = UIGravityBehavior()
        behavior.magnitude = 0
        return behavior
    }()

    func push(_ item: UIDynamicItem) {
        let pushBehavior = UIPushBehavior(items: [item], mode: .instantaneous)
        //카드 뷰가 화면의 모서리에 모여있지 않도록 push 애니메이션의 angle을 중앙을 향하도록 한다.
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y < center.y:
                pushBehavior.angle = (CGFloat.pi / 2).arc4random
            case let (x, y) where x > center.x && y < center.y:
                pushBehavior.angle = CGFloat.pi - (CGFloat.pi / 2).arc4random
            case let (x, y) where x < center.x && y > center.y:
                pushBehavior.angle = (-CGFloat.pi / 2).arc4random
            case let (x, y) where x < center.x && y < center.y:
                pushBehavior.angle = CGFloat.pi + (CGFloat.pi / 2).arc4random
            default:
                pushBehavior.angle = (CGFloat.pi * 2).arc4random
            }
        }
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
        gravityBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
        gravityBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
        addChildBehavior(gravityBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}

extension CGFloat {
    var arc4random: CGFloat {
        if self > 0 {
            return CGFloat(arc4random_uniform(UInt32(self - 1))) + CGFloat(drand48())
        } else if self < 0 {
            return -(CGFloat(arc4random_uniform(UInt32(abs(self - 1)))) + CGFloat(drand48()))
        } else {
            return 0
        }
    }
}
