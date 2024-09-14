//
//  GenreView.swift
//  songsurprise
//
//  Created by resoul on 12.09.2024.
//

import UIKit

class GenreView: UICollectionViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 0
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.centerXconstraint(for: self)
        titleLabel.centerYconstraint(for: self)
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }
    
    func configure(_ item: GenreModel) {
        titleLabel.text = item.name
        backgroundColor = UIColor(hex: item.backgroundColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
