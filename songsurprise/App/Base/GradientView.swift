//
//  GradientView.swift
//  songsurprise
//
//  Created by resoul on 12.09.2024.
//

import UIKit

class GradientView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [UIColor(hex: "#ea580c")!.cgColor, UIColor(hex: "#4f46e5")!.cgColor]
        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        l.cornerRadius = 8
        layer.insertSublayer(l, at: 0)
        return l
    }()
}
