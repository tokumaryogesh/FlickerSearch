//
//  SearchViewController.swift
//  FlickerSearch
//
//  Created by Yogesh Kumar on 27/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    var messageAlertView: AlertMessgaeView = {
        let messageView = AlertMessgaeView.loadNib() as! AlertMessgaeView
        messageView.translatesAutoresizingMaskIntoConstraints = false
        return messageView
    }()
    
    let viewModel = SearchViewModel()
    let progressIndicatorView = UIActivityIndicatorView(style: .gray)
    private var searchText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        prepareview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressIndicatorView.isHidden = true
    }
    
    private func prepareview() {
        
        collectionView.register(UINib(nibName: SearchPhotoCell.className, bundle: nil), forCellWithReuseIdentifier: SearchPhotoCell.className)
        collectionView.prefetchDataSource = self
        self.view.addSubview(messageAlertView)
        
        let subViews: [String: Any] = ["SB": searchBar!, "MV": messageAlertView]
        let vConstaint = NSLayoutConstraint.constraints(withVisualFormat: "V:[SB]-0-[MV]-0-|", metrics: nil, views: subViews)
        let hConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[MV]-0-|", metrics: nil, views: subViews)
        NSLayoutConstraint.activate( vConstaint + hConstraint)
        messageAlertView.isHidden = true
        
        viewModel.modelDidGetUpdated = { [weak self] error in
            guard let weakSelf = self else {
                return
            }
            weakSelf.progressIndicatorView.isHidden = true
            if let error = error, weakSelf.viewModel.photos.isEmpty {
                weakSelf.messageAlertView.isHidden = false
                weakSelf.messageAlertView.updateViewWith(imageName: "icon_wentwrong", message: error.localizedDescription)
                return
            }
            weakSelf.messageAlertView.isHidden = true
            weakSelf.collectionView.reloadData()
            if weakSelf.viewModel.photos.isEmpty {
                weakSelf.messageAlertView.isHidden = false
                weakSelf.messageAlertView.updateViewWith(imageName: "icon_wentwrong", message: DisplayMessagea.noResultFound)
            }
        }
        
        self.view.addSubview(progressIndicatorView)
        progressIndicatorView.startAnimating()
        progressIndicatorView.center = view.center
    }

}

// MARK:- UICollectionView DataSource, Delegate

extension SearchViewController: UICollectionViewDataSource {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchPhotoCell.className, for: indexPath) as? SearchPhotoCell
        cell?.updateCellWithInfo(viewModel.photos[indexPath.row])
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.searchBar.resignFirstResponder()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if  viewModel.photos.count > indexPath.row {
            if let url = URL(string: viewModel.photos[indexPath.row].urlForPhoto()) {
                ImageDownloadManager.shared.updatePriority(.high, forURL: url)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if viewModel.photos.count > indexPath.row {
            if let url = URL(string: viewModel.photos[indexPath.row].urlForPhoto()) {
                ImageDownloadManager.shared.updatePriority(.low, forURL: url)
            }
        }
    }
}

// MARK:- UICollectionView Prefetching

extension SearchViewController : UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        checkPrefetchingRequired(indexPaths)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
    }
    
    private func checkPrefetchingRequired(_ indexPaths: [IndexPath]) {
        if viewModel.isNextPageAvailable(), let searchText = searchText {
            let indexPath = IndexPath(item: viewModel.photos.count-1, section: 0)
            if indexPaths.contains(indexPath) {
                viewModel.getSearchForText(searchText, page: viewModel.currentPage() + 1)
            }
        }
    }
}

// MARK:- UICollectionView layout delegates for ItemSize

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfItems = SearchScreenConfig.noOfItemsHorizontally
        let dim = (UIScreen.main.bounds.width -  ((noOfItems - 1) * SearchScreenConfig.interItemSpacing)) / noOfItems
            return CGSize(width: dim, height: dim)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return SearchScreenConfig.interItemSpacing
    }
}

// MARK:- SearchBar Delegates

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text.count > 0  {
            searchText = text
            searchBar.resignFirstResponder()
            viewModel.resetSearch()
            viewModel.getSearchForText(text)
            progressIndicatorView.isHidden = false
            messageAlertView.isHidden = true
        }
    }
}
