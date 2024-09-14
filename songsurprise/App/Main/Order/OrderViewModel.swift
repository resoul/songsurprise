//
//  OrderViewModel.swift
//  songsurprise
//
//  Created by resoul on 12.09.2024.
//

import UIKit

final class OrderViewModel {
    private(set) var items: [OrderModel] = [
        OrderModel(icon: "idea", title: String(localized: "order.chose_track"), description: String(localized: "order.chose_track.desc")),
        OrderModel(icon: "settings", title: String(localized: "order.record_audio"), description: String(localized: "order.record_audio.desc")),
        OrderModel(icon: "like", title: String(localized: "order.pay_once"), description: String(localized: "order.pay_once.desc"))
    ]
    private(set) var itemCount: Int = 3
    
    func getCollectionView() -> UICollectionView {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.isPortrait() ? createLayoutForPortrait() : createLayoutForLandscape())
        view.register(cell: OrderViewCell.self)
        view.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: OrderReusableHeader.self)
        
        return view
    }
    
    func isPortrait() -> Bool {
        return UIScreen.main.bounds.height > UIScreen.main.bounds.width
    }
    
    func getRoute(index: Int) -> UIViewController {
        return GenreController()
    }
    
    func hideOrderCollectionView() {
        itemCount = 0
    }
    
    func showOrderCollectionView() {
        itemCount = 3
    }
    
    func createLayoutForLandscape() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8)
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func createLayoutForPortrait() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.29))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8)
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
