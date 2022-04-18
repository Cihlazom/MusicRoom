//
//  CMTime.swift
//  MusicRoom
//
//  Created by Vladislav on 16.04.2022.
//

import Foundation
import AVKit

extension CMTime {
    func toString() -> String {
        guard !CMTimeGetSeconds(self).isNaN else {return ""}
        let totalsecond = Int(CMTimeGetSeconds(self))
        let seconds = totalsecond % 60
        let minutes = totalsecond / 60
        let timeFormatString = String(format: "%02d:%02d", arguments: [minutes,seconds])
        return timeFormatString
    }
}
