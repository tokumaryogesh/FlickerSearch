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
    
    let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        prepareview()
    }
    
    private func prepareview() {
        
        collectionView.register(UINib(nibName: SearchPhotoCell.className, bundle: nil), forCellWithReuseIdentifier: SearchPhotoCell.className)
        collectionView.prefetchDataSource = self
    }

}

// MARK:- UICollectionView DataSource, Delegate

extension SearchViewController: UICollectionViewDataSource {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.dataSource?.photos.photo.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchPhotoCell", for: indexPath) as? SearchPhotoCell
        if let data = viewModel.dataSource?.photos.photo[indexPath.row] {
            cell?.updateCellWithInfo(data)
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.searchBar.resignFirstResponder()
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
                viewModel.getSearchForText(searchBar.text ?? "", page: list.page + 1) { [weak self] in
                    self?.collectionView.reloadData()
                }
            }
        }
    }
}

// MARK:- UICollectionView ItemSize

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
            collectionView.reloadData()
            viewModel.getSearchForText(text) { [weak self] in
                // Data download completed
                
                self?.collectionView.reloadData()
            }
        }
    }
}
