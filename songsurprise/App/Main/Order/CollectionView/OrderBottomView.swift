//
//  OrderBottomView.swift
//  songsurprise
//
//  Created by resoul on 12.09.2024.
//

import UIKit

class OrderBottomView: UIView {
    
    private lazy var musicIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "music")?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        
        return view
    }()
    
    private lazy var musicLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .left
        label.textColor = UIColor.label
        label.numberOfLines = 1
        
        return label
    }()
    
    func configure(_ text: String) {
        musicLabel.text = text
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(musicIcon, musicLabel)
        musicIcon.constraints(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0), size: .init(width: 22, height: 22))
        musicLabel.constraints(top: topAnchor, leading: musicIcon.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 10, bottom: 0, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
