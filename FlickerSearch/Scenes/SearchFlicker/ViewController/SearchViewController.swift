//
//  SearchViewController.swift
//  FlickerSearch
//
//  Created by Yogesh Kumar on 27/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let params = FlickerSearchRequestParameters(searchString: "kitten")
        let getRequest = GetRequestDTO(queryParameter: params, url: FLICKR.baseUrl)
        let service = FlickerSearchService()
        service.getRequest(requestDto: getRequest, responseDto: SearchResponseDTO.self) { result in
            
            switch result {
            case .Success(let responseDTO):
                print(responseDTO)
            case .Failure(let error):
                print("error \(error)")
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
