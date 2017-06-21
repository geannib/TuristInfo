//
//  TICustomMerker.swift
//  TuristInfo
//
//  Created by Apple on 08/03/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit


protocol TICustomMarkerDelegate: class {
    func playAsset()
}

class TICustomMarker: UIView {

    weak var delegate:TICustomMarkerDelegate?
    
    @IBOutlet weak var buttonPlayAsset: UIButton!
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBAction func actionButtonPlay(_ sender: Any) {
        
        self.delegate?.playAsset()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
