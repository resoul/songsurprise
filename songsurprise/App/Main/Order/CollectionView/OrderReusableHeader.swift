//
//  OrderReusableHeader.swift
//  songsurprise
//
//  Created by resoul on 12.09.2024.
//

import UIKit

final class OrderReusableHeader: UICollectionReusableView {
    
    private lazy var headerTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .label
        label.text = String(localized: "order.reusable_header")
        
        return label
    }()
    
    private lazy var progressView = UIProgressView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(headerTitle, progressView)
        headerTitle.centerXconstraint(for: self)
        headerTitle.centerYconstraint(for: self)
        progressView.constraints(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 10))
        progressView.setProgress(0.33, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
