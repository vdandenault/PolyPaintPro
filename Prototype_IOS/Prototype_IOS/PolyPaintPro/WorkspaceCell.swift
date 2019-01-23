//
//  WorkspaceCell.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-03.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import UIKit

class WorkspaceCell: UITableViewCell {
    
    @IBOutlet weak var workspaceCellTextField: UILabel!
    
    func setWorkspaceCell(workspace: Workspace) {
       workspaceCellTextField.text = workspace.name
    }
}
