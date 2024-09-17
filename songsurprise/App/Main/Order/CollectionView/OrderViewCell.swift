//
//  OrderViewCell.swift
//  songsurprise
//
//  Created by resoul on 12.09.2024.
//

import UIKit

final class OrderViewCell: UICollectionViewCell {
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor(hex: "#9ca3af")!
        
        return label
    }()
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor(hex: "#0f172a")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .left
        label.textColor = UIColor(hex: "#9ca3af")!
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var bottomView = OrderBottomView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(headerLabel, iconView, descriptionLabel, bottomView)
        iconView.constraints(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 50, height: 50))
        headerLabel.constraints(top: topAnchor, leading: iconView.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 0, height: 50))
        descriptionLabel.constraints(top: headerLabel.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 10, left: 10, bottom: 0, right: 10))
        bottomView.constraints(top: descriptionLabel.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 15, left: 10, bottom: 0, right: 10))
        bottomView.isHidden = true
    }
    
    func configure(order: OrderModel) {
        headerLabel.text = order.title
        iconView.image = UIImage(named: order.icon)
        descriptionLabel.text = order.description
    }
    
    func configureBottomView(index: Int) {
        if index == 0 && UserDefaults.standard.integer(forKey: "userSelectedTrackId") != 0, let text = UserDefaults.standard.string(forKey: "userSelectedTrackName") {
            bottomView.isHidden = false
            bottomView.configure(text)
        } else {
            bottomView.isHidden = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let gradient = getGradientLayer(bounds: headerLabel.bounds)
        headerLabel.textColor = gradientColor(bounds: headerLabel.bounds, gradientLayer: gradient)
    }
    
    func gradientColor(bounds: CGRect, gradientLayer : CAGradientLayer) -> UIColor? {
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return UIColor(patternImage: image!)
    }
    
    func getGradientLayer(bounds : CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [UIColor(hex: "#ea580c")!.cgColor, UIColor(hex: "#4f46e5")!.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        return gradient
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
