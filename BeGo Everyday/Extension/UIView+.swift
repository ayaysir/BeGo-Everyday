//
//  UIView+.swift
//  BeGo Everyday
//
//  Created by yoonbumtae on 2023/02/10.
//

import UIKit

extension UIView {
    // https://stackoverflow.com/a/41197790
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
