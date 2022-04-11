//
//  ViewController.swift
//  HomePagePOC
//
//  Created by Zulwiyoza Putra on 25/01/22.
//

import UIKit

class Label: UILabel {
    var contentInsets: UIEdgeInsets = .zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size: CGSize = super.sizeThatFits(size)
        size.width += contentInsets.left + contentInsets.right
        size.height += contentInsets.top + contentInsets.bottom
        
        return size
    }
    
    override var intrinsicContentSize: CGSize {
        var size: CGSize = super.intrinsicContentSize
        size.height += contentInsets.top + contentInsets.bottom
        size.width += contentInsets.left + contentInsets.right
        return size
    }
}

extension UIViewController {
    
    var statusBarSize: CGSize {
        if #available(iOS 13, *) {
            return view.window?.windowScene?.statusBarManager?.statusBarFrame.size ?? .zero
        } else {
            return UIApplication.shared.statusBarFrame.size
        }
    }
    
    var estimatedVisibleViewSize: CGSize {
        if isViewLoaded {
            var size: CGSize = view.frame.size
            size.height -= statusBarSize.height
            size.height -= navigationController?.navigationBar.frame.height ?? 0.0
            size.height -= tabBarController?.tabBar.frame.height ?? 0.0
            return size.height >= 0 ? size : .zero
        } else {
            return .zero
        }
    }
}

enum ScrollState {
    case pending
    case scrolling
    case ended
}

enum ScrollDirection {
    case pending
    case up
    case down
}

class ViewController: UIViewController, TableViewControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    private lazy var productDirectoryViewController: ProductDirectoryViewController = {
        let controller: ProductDirectoryViewController = ProductDirectoryViewController(products: ProductDirectoryViewController.products)
        return controller
    }()
    
    private let headerView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .systemPink
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let borderLabel: Label = {
        let label: Label = Label()
        label.textAlignment = .center
        label.backgroundColor = UIColor.secondarySystemBackground
        label.text = "BorderLabel"
        label.contentInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var scrollView: UIScrollView = {
        let view: UIScrollView = UIScrollView()
        view.backgroundColor = UIColor.systemBackground
        view.clipsToBounds = false
        return view
    }()
    
    private lazy var redViewController: TableViewController = {
        let controller: TableViewController = TableViewController()
        controller.title = "Red"
        controller.delegate = self
        return controller
    }()
    
    private lazy var blueViewController: TableViewController = {
        let controller: TableViewController = TableViewController()
        controller.title = "Blue"
        controller.delegate = self
        return controller
    }()
    
    private lazy var pageViewController: PageViewController = {
        let controller: PageViewController = PageViewController(managedViewControllers: [redViewController, blueViewController], transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return controller
    }()
    
    private lazy var navigationBarAppearance: UINavigationBarAppearance = {
        let appearance: UINavigationBarAppearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        return appearance
    }()
    
    private lazy var tabBarAppearance: UITabBarAppearance = {
        let appearance: UITabBarAppearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        return appearance
    }()
    
    private let headerViewHeight: CGFloat = 400.0
    
    private var pageViewHeightConstraint: NSLayoutConstraint!
    
    var scrollState: ScrollState = .pending
    var scrollDirection: ScrollDirection = .pending
    var lastContentOffset: CGPoint = .zero
    
    override func loadView() {
        view = scrollView
        scrollView.delegate = self
    }
    
    private func setupHeaderView(topAnchor: NSLayoutYAxisAnchor) {
        pageViewController.addChild(productDirectoryViewController)

        productDirectoryViewController.view.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(productDirectoryViewController.view)
        NSLayoutConstraint.activate([
            productDirectoryViewController.view.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            productDirectoryViewController.view.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            productDirectoryViewController.view.topAnchor.constraint(equalTo: headerView.topAnchor),
            productDirectoryViewController.view.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        
        scrollView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            headerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerViewHeight)
        ])
    }
    
    private func setupBorderLabel(topAnchor: NSLayoutYAxisAnchor) {
        scrollView.addSubview(borderLabel)
        NSLayoutConstraint.activate([
            borderLabel.topAnchor.constraint(equalTo: topAnchor),
            borderLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            borderLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            borderLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            borderLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
    }
    
    private func setupContentView(topAnchor: NSLayoutYAxisAnchor) {
        addChild(pageViewController)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(pageViewController.view)
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: topAnchor),
            pageViewController.view.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ])
        
        pageViewHeightConstraint = pageViewController.view.heightAnchor.constraint(equalToConstant: estimatedVisibleViewSize.height)
        pageViewHeightConstraint.isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        tabBarController?.tabBar.standardAppearance = tabBarAppearance
        tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
        setupHeaderView(topAnchor: scrollView.topAnchor)
        setupBorderLabel(topAnchor: headerView.bottomAnchor)
        setupContentView(topAnchor: borderLabel.bottomAnchor)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//            self.scrollingDecelerator.decelerate(by: ScrollingDeceleration(velocity: CGPoint(x: 0, y: 300), decelerationRate: UIScrollView.DecelerationRate(rawValue: 0.3)))
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageViewHeightConstraint.constant = estimatedVisibleViewSize.height - borderLabel.frame.height
    }
    
    func setActivePagingScrollViewVerticalContentOffset(_ verticalOffset: CGFloat) {
        if let scrollable: ScrollableViewController = pageViewController.activeViewController as? ScrollableViewController {
            var contentOffset = scrollable.scrollViewContentOffset
            contentOffset.y += verticalOffset
            scrollable.setScrollViewContentOffset(contentOffset)
        }
    }
    
    private lazy var scrollingDecelerator: ScrollingDecelerator = ScrollingDecelerator(scrollView: self.scrollView)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard borderLabel.frame.origin.y != 0.0 else { return }
        
        let isBorderLabelReachingTopBound: Bool = self.scrollView.adjustedContentOffset.y >= borderLabel.frame.origin.y
        if isBorderLabelReachingTopBound && borderLabel.frame.origin.y != 0.0 {
            scrollState = .ended
            // Store transferable vertical offset before updates
            let transferableVerticalOffset = scrollView.adjustedContentOffset.y - borderLabel.frame.origin.y

            // Lock scroll view content offset
            var contentOffset: CGPoint = scrollView.adjustedContentOffset
            contentOffset.y = borderLabel.frame.origin.y
            scrollView.setAdjustedContentOffset(contentOffset)
            
//            self.scrollView.panGestureRecognizer.isEnabled = false
//            scrollView.panGestureRecognizer.isEnabled = true
////            scrollView.isScrollEnabled = false
//
//            // Transfer remainder content offset to active scrollable
            setActivePagingScrollViewVerticalContentOffset(transferableVerticalOffset)
        } else {
            scrollState = .scrolling
            
            if let scrollable: ScrollableViewController = pageViewController.activeViewController as? ScrollableViewController {
//                scrollable.setScrollViewContentOffset(.zero)
//                scrollable.setPanGestureRecognizerEnabled(false)
////                redViewController.tableView.isScrollEnabled = false
                
                if scrollable.scrollViewContentOffset.y > 0.0 {
                    var contentOffset: CGPoint = scrollView.adjustedContentOffset
                    contentOffset.y = borderLabel.frame.origin.y
                    scrollView.setAdjustedContentOffset(contentOffset)
                    
                    scrollState = .ended
                }
            }
        }
        
        if scrollView.adjustedContentOffset.y > lastContentOffset.y {
            scrollDirection = .up
        } else {
            scrollDirection = .down
        }
        
        lastContentOffset = scrollView.adjustedContentOffset
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print(velocity)
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        outerDeceleration = nil
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        outerDeceleration = nil
    }
    
    func tableViewController(_ controller: TableViewController, scrollViewDidScroll scrollView: UIScrollView) {
        if scrollState == .scrolling {
            controller.setScrollViewContentOffset(.zero)
        }
        
//        let isUserPullingScrollView: Bool = scrollView.contentOffset.y <= 0
//        let isBorderLabelReachingTopBound: Bool = self.scrollView.adjustedContentOffset.y >= borderLabel.frame.origin.y
//        let shouldTransferExcessOffset: Bool = !isBorderLabelReachingTopBound || isUserPullingScrollView
////////        controller.setDeceleratorInvalidateIfNeeded()
//        if shouldTransferExcessOffset {
//            print("hehe")
//            // Set interacting scroll view content offset to zero
//            scrollView.setContentOffset(.zero, animated: false)
////            controller.setPanGestureRecognizerEnabled(false)
//
////            self.scrollView.panGestureRecognizer.isEnabled = true
//
//            // Adjust main scroll view content offset
//            var targetOffset: CGPoint = self.scrollView.adjustedContentOffset
//            targetOffset.y += scrollView.contentOffset.y
//            self.scrollView.setAdjustedContentOffset(targetOffset, animated: false)
////            self.scrollView.panGestureRecognizer.isEnabled = true
//////            redViewController.tableView.isScrollEnabled = false
//
//        } else {
//            print("haha")
////            controller.setPanGestureRecognizerEnabled(true)
////            redViewController.tableView.isScrollEnabled = true
//        }
    }
    
    func tableViewController(_ controller: TableViewController, scrollViewWillEndDragging scrollView: UIScrollView, velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //        let isPullingScrollView: Bool = scrollView.contentOffset.y <= 0
//        let hasBorderLabelReachingTop: Bool = self.scrollView.adjustedContentOffset.y >= borderLabel.frame.origin.y
//        let shouldTransferExcessOffset: Bool = !hasBorderLabelReachingTop || isPullingScrollView
////
//        if shouldTransferExcessOffset {
//
//            scrollingDecelerator.decelerate(by: ScrollingDeceleration(velocity: velocity, decelerationRate: scrollView.decelerationRate))
//        }
        
    }
    
    func tableViewController(_ controller: TableViewController, scrollViewDidChangeAdjustedContentInsetForScrollView scrollView: UIScrollView) {
        return
    }
}



extension UIScrollView {
    var adjustedContentOffset: CGPoint {
        var offset: CGPoint = contentOffset
        offset.x += adjustedContentInset.left
        offset.y += adjustedContentInset.top
        return offset
    }
    
    var isScrolling: Bool {
        return isTracking || isDragging || isDecelerating
    }
    
    func setAdjustedContentOffset(_ point: CGPoint, animated: Bool = false) {
        var mutable: CGPoint = point
        mutable.x -= adjustedContentInset.left
        mutable.y -= adjustedContentInset.top
        if animated {
            setContentOffset(mutable, animated: animated)
        } else {
            contentOffset = mutable
        }
        
    }
}

class ContainerViewController: UIViewController {
    
    let preferredBackgroundColor: UIColor?
    
    let preferredLabelTitle: String
    
    private lazy var label: UILabel = UILabel()
    
    required init(preferredLabelTitle: String, preferredBackgroundColor: UIColor?) {
        self.preferredLabelTitle = preferredLabelTitle
        self.preferredBackgroundColor = preferredBackgroundColor
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = preferredBackgroundColor
        
        label.text = preferredLabelTitle
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 16.0),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16.0),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16.0),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16.0),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct Product {
    let title: String
}


protocol ScrollableViewController: UIViewController {
    var scrollViewContentInset: UIEdgeInsets { get }
    var scrollViewAdjustedContentInset: UIEdgeInsets { get }
    var scrollViewContentOffset: CGPoint { get }
    func setScrollViewContentInset(_ inset: UIEdgeInsets)
    func setScrollViewContentOffset(_ offset: CGPoint)
    func setPanGestureRecognizerEnabled(_ isEnabled: Bool)
}

protocol TableViewControllerDelegate: AnyObject {
    func tableViewController(_ controller: TableViewController, scrollViewWillEndDragging scrollView: UIScrollView, velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    func tableViewController(_ controller: TableViewController, scrollViewDidScroll scrollView: UIScrollView)
    func tableViewController(_ controller: TableViewController, scrollViewDidChangeAdjustedContentInsetForScrollView scrollView: UIScrollView)
}

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ScrollableViewController, UIGestureRecognizerDelegate {
    var scrollViewContentInset: UIEdgeInsets {
        return tableView.contentInset
    }
    
    var scrollViewAdjustedContentInset: UIEdgeInsets {
        return tableView.adjustedContentInset
    }
    
    var scrollViewContentOffset: CGPoint {
        return tableView.contentOffset
    }
    
    func setScrollViewContentInset(_ inset: UIEdgeInsets) {
        tableView.contentInset = inset
    }
    
    func setScrollViewContentOffset(_ offset: CGPoint) {
        tableView.contentOffset = offset
    }
    
    func setPanGestureRecognizerEnabled(_ isEnabled: Bool) {
        tableView.panGestureRecognizer.isEnabled = isEnabled
    }
    
    private var previousContentOffset: CGPoint = .zero
    
    weak var delegate: TableViewControllerDelegate?
    
    private(set) lazy var tableView: UITableView = {
        let tableView = TableView()
        tableView.panDelegate = self
        return tableView
    }()
    
    private lazy var items: [String] = {
        return (0...100).map { index in
            "\(title ?? "Index") \(index)"
        }
    }()
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(String(describing: title)) appear")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        var config = UIListContentConfiguration.cell()
        config.text = items[indexPath.row]
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.tableViewController(self, scrollViewDidScroll: scrollView)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        delegate?.tableViewController(self, scrollViewDidChangeAdjustedContentInsetForScrollView: scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.tableViewController(self, scrollViewWillEndDragging: scrollView, velocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let viewController: ViewController = delegate as? ViewController {
            if otherGestureRecognizer == viewController.scrollView.panGestureRecognizer {
                return true
            } else {
                return false
            }
        }
        return false
    }
}

class TableView: UITableView, UIGestureRecognizerDelegate {
    weak var panDelegate: UIGestureRecognizerDelegate?
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let delegate = panDelegate {
            if let result = delegate.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
                return result
            }
        }
        return false
    }
}
