/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import UIKit

extension UIColor {

    /**
     Returns the teal color
     */
    class func tealColor() -> UIColor {
        
        return UIColor.init(colorLiteralRed: 0/255, green: 150/255, blue: 136/255, alpha: 1)
    }
    
    /**
     Returns the light gray color used in rumpel
     */
    class func rumpelLightGray() -> UIColor {
        
        return UIColor.init(colorLiteralRed: 51/255, green: 74/255, blue: 79/255, alpha: 1)
    }
    
    /**
     Returns the dark gray color used in rumpel
     */
    class func rumpelDarkGray() -> UIColor {
        
        return UIColor.init(colorLiteralRed: 29/255, green: 49/255, blue: 53/255, alpha: 1)
    }
    
    /**
     Returns the very light gray color used in rumpel
     */
    class func rumpelVeryLightGray() -> UIColor {
        
        return UIColor.init(colorLiteralRed: 244/255, green: 244/255, blue: 244/255, alpha: 1)
    }
}
