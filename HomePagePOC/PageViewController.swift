//
//  HomePageViewController.swift
//  HomePagePOC
//
//  Created by Zulwiyoza Putra on 08/02/22.
//

import UIKit

// MARK: - HomePageViewController
class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    let managedViewControllers: [ScrollableViewController]
    
    private(set) lazy var activeViewController: UIViewController = managedViewControllers.first!
    
    required init(managedViewControllers: [ScrollableViewController], transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        self.managedViewControllers = managedViewControllers
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers([managedViewControllers.first!], direction: .forward, animated: false, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = managedViewControllers.firstIndex(where: { $0  == viewController }) else { return nil }
        guard index >= 1 else { return nil }
        return managedViewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = managedViewControllers.firstIndex(where: { $0  == viewController }) else { return nil }
        guard index < managedViewControllers.count-1 else { return nil }
        return managedViewControllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        activeViewController = viewControllers!.first!
    }
}
