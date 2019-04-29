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
            self?.progressIndicatorView.isHidden = true
            let dataSourceCount = self?.viewModel.dataSource?.photos.photo.count ?? 0
            if let error = error, dataSourceCount == 0 {
                self?.messageAlertView.isHidden = false
                self?.messageAlertView.updateViewWith(imageName: "icon_wentwrong", message: error.localizedDescription)
                return
            }
            self?.messageAlertView.isHidden = true
            self?.collectionView.reloadData()
            if let count = self?.viewModel.dataSource?.photos.photo.count, count == 0 {
                self?.messageAlertView.isHidden = false
                self?.messageAlertView.updateViewWith(imageName: "icon_wentwrong", message: DisplayMessagea.noResultFound)
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
        return viewModel.dataSource?.photos.photo.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchPhotoCell.className, for: indexPath) as? SearchPhotoCell
        if let data = viewModel.dataSource?.photos.photo[indexPath.row] {
            cell?.updateCellWithInfo(data)
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.searchBar.resignFirstResponder()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let photos = viewModel.dataSource?.photos.photo, photos.count > indexPath.row {
            if let url = URL(string: photos[indexPath.row].urlForPhoto()) {
                ImageDownloadManager.shared.updatePriority(.high, forURL: url)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let photos = viewModel.dataSource?.photos.photo, photos.count > indexPath.row {
            if let url = URL(string: photos[indexPath.row].urlForPhoto()) {
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
        if let list = viewModel.dataSource?.photos, list.page < list.pages {
            let indexPath = IndexPath(item: list.photo.count-1, section: 0)
            if indexPaths.contains(indexPath) {
                viewModel.getSearchForText(searchBar.text ?? "", page: list.page + 1)
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
            searchBar.resignFirstResponder()
            viewModel.resetSearch()
            viewModel.getSearchForText(text)
            progressIndicatorView.isHidden = false
            messageAlertView.isHidden = true
        }
    }
}
