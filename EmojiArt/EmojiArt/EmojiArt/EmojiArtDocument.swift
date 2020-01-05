//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Soojung Shin on 2020/01/05.
//  Copyright © 2020 Soojung Shin. All rights reserved.
//

import UIKit

class EmojiArtDocument: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

