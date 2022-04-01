//
//  ProductDirectoryViewController.swift
//  HomePagePOC
//
//  Created by Zulwiyoza Putra on 08/02/22.
//

import UIKit

class ProductDirectoryFlowLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()
        scrollDirection = .horizontal
        minimumInteritemSpacing = 16
        minimumLineSpacing = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol VerticallyScrollableDelegate: AnyObject {
    func productDirecoryViewShouldHitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
}

class ProductDirectoryViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    static let products: [Product] = {
        return (0...50).map { num in
            Product(title: "Product \(num)")
        }
    }()
    
    private let products: [Product]
    
    private let collectionView: UICollectionView = {
        let view: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: ProductDirectoryFlowLayout())
        return view
    }()
    
    required init(products: [Product]) {
        self.products = products
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.isPagingEnabled = true
        collectionView.isDirectionalLockEnabled = true
//        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: String(describing: UICollectionViewCell.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UICollectionViewCell.self), for: indexPath)
        var configuration: UIListContentConfiguration = UIListContentConfiguration.cell()
        configuration.image = UIImage(systemName: "square.fill")
        configuration.text = products[indexPath.row].title
        cell.contentConfiguration = configuration
        cell.contentView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.cornerRadius = 6.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height - 32
        return CGSize(width: height, height: height)
    }
}

