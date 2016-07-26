//
//  YonaVPNProgressIconView.swift
//  Yona
//
//  Created by Anders Liebl on 26/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

enum progressIconEnum {
    case yonaApp
    case openVPN
    case profile

}

class YonaVPNProgressIconView: UIView {
    
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var statusView :UIImageView!

    
    func confugureView (type : progressIconEnum, completed : Bool) {
        switch type {
        case .yonaApp:
            infoLabel.text = NSLocalizedString("YonaVPNProgressView.yonaapp.text", comment: "")
            iconView.image = UIImage(named: "icnYona")
            
        case .openVPN:
            infoLabel.text = NSLocalizedString("YonaVPNProgressView.openvpn.text", comment: "")
            iconView.image = UIImage(named: "icnOpenVPN")
        case .profile:
            infoLabel.text = NSLocalizedString("YonaVPNProgressView.profile.text", comment: "")
            iconView.image = UIImage(named: "icnSettings")
        }
        if completed {
            statusView.image = UIImage(named: "greenSelected")
        } else {
            statusView.image = UIImage(named: "greenNotSelected")
        }
    }

    func setText (aString : String ) {
        infoLabel.text = aString
    }
}