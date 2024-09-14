//
//  MainController.swift
//  songsurprise
//
//  Created by resoul on 12.09.2024.
//

import UIKit

class MainController: UIViewController {
    
    private let orderViewModel = OrderViewModel()
    private lazy var orderCollectionView: UICollectionView = {
        let view = orderViewModel.getCollectionView()
        view.dataSource = self
        view.delegate = self
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(orderCollectionView)
        orderCollectionView.constraints(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        StorageManager.shared.cacheAudioFilesIfNeeded()
        print(UserDefaults.standard.integer(forKey: "userSelectedTrackId"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        orderViewModel.hideOrderCollectionView()
        guard UserDefaults.standard.bool(forKey: "showOnbordController") == false else {
            orderViewModel.showOrderCollectionView()
            orderCollectionView.reloadData()
            return
        }
        
        let controller = OnboardController(items: orderViewModel.items)
        controller.delegate = self
        controller.modalPresentationStyle = .overCurrentContext
        parent?.present(controller, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.orderCollectionView.collectionViewLayout = self.orderViewModel.isPortrait()
            ? self.orderViewModel.createLayoutForPortrait() : self.orderViewModel.createLayoutForLandscape()
        })
    }
}

extension MainController: OnboardDelegate {
    func didViewAllScreens() {
        UserDefaults.standard.setValue(true, forKey: "showOnbordController")
        UserDefaults.standard.synchronize()
        orderViewModel.showOrderCollectionView()
        orderCollectionView.reloadData()
        dismiss(animated: true)
    }
}

extension MainController: CollectionViewProvider {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withClass: OrderReusableHeader.self, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderViewModel.itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        navigationController?.pushViewController(orderViewModel.getRoute(index: indexPath.row), animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: OrderViewCell.self, for: indexPath)
        cell.configure(order: orderViewModel.items[indexPath.row])
        
        return cell
    }
}
