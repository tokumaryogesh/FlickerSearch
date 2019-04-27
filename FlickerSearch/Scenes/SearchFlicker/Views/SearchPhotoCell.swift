//
//  SearchPhotoCell.swift
//  FlickerSearch
//
//  Created by Yogesh Kumar on 27/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import UIKit

protocol PhotoResultProtocol {
    
    var farm: Int {get}
    var server: String {get}
    var secret: String {get}
    var id: String {get}
    
}


class SearchPhotoCell: UICollectionViewCell, ClassName {

    @IBOutlet weak var photoImageView: UIImageView!
    var data: PhotoResultProtocol?
    var photoUrl: URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateCellWithInfo(_ info: PhotoResultProtocol) {
        
        data = info
        self.photoImageView.image = UIImage.init(named: "placeholder_cover")
        let urlString = createUrlFromData(data: info)
        if let url = URL(string: urlString) {
            self.photoUrl = url
            ImageDownloadManager.shared.downloadImageWithUrl(url, completionHandler: { [weak self]  (image, url, error) in
                if let photoUrl = self?.photoUrl, let image = image, photoUrl == url {
                    self?.photoImageView.image = image
                }
            })
        }
        
    }
    
    func createUrlFromData(data: PhotoResultProtocol) -> String {
        return "http://farm" + String(data.farm) + ".static.flickr.com/" + data.server + "/" + data.id + "_" + data.secret + ".jpg"
    }

}
