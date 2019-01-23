//
//  Image.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 18-10-26.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation

import Foundation

struct Image {
    var metaData: MetaData
    var editor: Editor
    
    init() {
        self.metaData = MetaData.init()
        self.editor = Editor.init()
    }
    
    init(metaData: MetaData, editor:Editor) {
        self.metaData = metaData
        self.editor = editor
    }
}
