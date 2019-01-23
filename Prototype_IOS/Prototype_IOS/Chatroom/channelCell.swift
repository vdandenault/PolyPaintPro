//
//  channelCell.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-10-12.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import UIKit

class channelCell: UITableViewCell {
    
    @IBOutlet weak var channelName: UILabel!
    
    func setChannel(channel: Channel) {
        channelName.text = channel.channelName
    }
}

