//
//  OverlayViewController.swift
//  iOS Sample
//
//  Copyright (c) 2017 Kazuhiro Hayashi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import PagingKit

class OverlayViewController: UIViewController {
    
    let dataSource: [(menu: String, content: UIViewController)] = ["Martinez", "Alfred", "Louis", "Justin", "Tim", "Deborah", "Michael", "Choi", "Hamilton", "Decker", "Johnson", "George"].map {
        let title = $0
        let vc = UIStoryboard(name: "ContentTableViewController", bundle: nil).instantiateInitialViewController() as! ContentTableViewController
        return (menu: title, content: vc)
    }

    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuViewController?.register(nib: UINib(nibName: "OverlayMenuCell", bundle: nil), forCellWithReuseIdentifier: "identifier")
        menuViewController?.registerFocusView(nib: UINib(nibName: "OverlayFocusView", bundle: nil), isBehindCell: true)
        menuViewController?.reloadData(with: 0, completionHandler: { [weak self, menuViewController = menuViewController!] (vc) in
            let cell = self?.menuViewController.currentFocusedCell as! OverlayMenuCell
            cell.setFrame(menuViewController.menuView, maskFrame: menuViewController.focusView.frame, animated: false)
        })
        contentViewController?.scrollView.bounces = true
        contentViewController?.reloadData(with: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController?.dataSource = self
            menuViewController?.delegate = self
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController?.delegate = self
            contentViewController?.dataSource = self
        }
    }
}

extension OverlayViewController: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)  as! OverlayMenuCell
        cell.titleLabel.text = dataSource[index].menu
        cell.highlightLabel.text = dataSource[index].menu
        cell.setFrame(viewController.menuView, maskFrame: menuViewController.focusView.frame, animated: false)
        return cell
    }

    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        OverlayMenuCell.sizingCell.titleLabel.text = dataSource[index].menu
        var referenceSize = UIView.layoutFittingCompressedSize
        referenceSize.height = viewController.view.bounds.height
        let size = OverlayMenuCell.sizingCell.systemLayoutSizeFitting(referenceSize, withHorizontalFittingPriority: UILayoutPriority.defaultLow, verticalFittingPriority: UILayoutPriority.defaultHigh)
        return size.width
    }
    
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
}


extension OverlayViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].content
    }
}

extension OverlayViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController?.scroll(to: page, animated: true)
    }
    
    func menuViewController(viewController: PagingMenuViewController, willAnimateFocusViewTo index: Int, with coordinator: PagingMenuFocusViewAnimationCoordinator) {
        viewController.visibleCells.compactMap { $0 as? OverlayMenuCell }.forEach { cell in
            cell.setFrame(viewController.menuView, maskFrame: coordinator.beginFrame, animated: true)
        }
        
        coordinator.animateFocusView(alongside: { coordinator in
            viewController.visibleCells.compactMap { $0 as? OverlayMenuCell }.forEach { cell in
                cell.setFrame(viewController.menuView, maskFrame: coordinator.endFrame, animated: true)
            }
        }, completion: nil)
    }
    
    func menuViewController(viewController: PagingMenuViewController, willDisplay cell: PagingMenuViewCell, forItemAt index: Int) {
        (cell as? OverlayMenuCell)?.setFrame(viewController.menuView, maskFrame: menuViewController.focusView.frame, animated: false)
    }
}

extension OverlayViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController.scroll(index: index, percent: percent, animated: false)
        menuViewController.visibleCells.forEach {
            let cell = $0 as! OverlayMenuCell
            cell.setFrame(menuViewController.menuView, maskFrame: menuViewController.focusView.frame, animated: false)
        }
    }
}
