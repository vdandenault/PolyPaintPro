//
//  Sounds.swift
//  Prototype_IOS
//
//  Created by Vincent Dandenault on 2018-11-11.
//  Copyright © 2018 Vincent Dandenault. All rights reserved.
//

import Foundation
import AVFoundation

class Sounds {

    var audioPlayer = AVAudioPlayer()
    
    static let shared = Sounds()
 
    func playSounds(fileName: String) {
        let soundURL = Bundle.main.url(forResource: fileName, withExtension: "mp3")
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
        }
        catch {
            print(error.localizedDescription)
        }
        self.audioPlayer.play()
    }
}

