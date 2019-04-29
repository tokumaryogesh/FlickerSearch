//
//  BaseService.swift
//  FlickerSearch
//
//  Created by Yogesh Kumar on 27/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Foundation

enum ServiceError: Error {
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case jsonParsingFailure
    case noInternetConnection
    
    var localizedDescription: String {
        switch self {
        case .requestFailed: return "Request Failed"
        case .invalidData: return "Invalid Data"
        case .responseUnsuccessful: return "Response Unsuccessful"
        case .jsonParsingFailure: return "JSON Parsing Failure"
        case .jsonConversionFailure: return "JSON Conversion Failure"
        case .noInternetConnection : return "No internert Connection. You are appear to be offline"
        }
    }
}

protocol ContainsUrl {
    var url: String {get set}
}

protocol GetRequestDTOProtocol: ContainsUrl {
    associatedtype Parameters: Encodable
    var queryParameter: Parameters? {get set}
}

enum Result<T> {
    case Success(T)
    case Failure(ServiceError)
}

extension Encodable {
    subscript(key: String) -> Any? {
        return dictionary[key]
    }
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
}

struct GetRequestDTO <QueryParameter : Encodable> : GetRequestDTOProtocol {
    var queryParameter: QueryParameter?
    var url: String
}
extension GetRequestDTO {
    init(url: String, queryParameter: QueryParameter) {
        self.url = url
        self.queryParameter = queryParameter
    }
}

class BaseService<ResponseDTO: Decodable> {
    
    fileprivate func decodeResponse(data : Data?,response:HTTPURLResponse?,error :Error?,responseDto:ResponseDTO.Type , completion :  (Result<ResponseDTO>)->Void) ->Void {
        guard let httpResponse = response else {
            completion(Result.Failure(.requestFailed))
            return
        }
        if statusCodeForResponseWith(code: httpResponse.statusCode) == .success {
            if let data = data {
                do {
                    let genericModel = try JSONDecoder().decode(responseDto, from: data)
                    completion(Result.Success(genericModel))
                } catch {
                    print("Conversion Failure \(error)")
                    completion(Result.Failure(.jsonConversionFailure))
                }
            } else {
                completion(Result.Failure(.invalidData))
            }
        } else {
            debugPrint("Response Failure : \(httpResponse)")
            completion(Result.Failure(.responseUnsuccessful))
        }
    }
    func getDictionary(parameterBody : Encodable) -> [String : Any] {
        return parameterBody.dictionary
    }
}

extension BaseService {
    
    enum StatusCode: Int {
        case success
        case unauthorized
        case internalServerError
        case versionUnsupported
        case undefined
    }
    
    func statusCodeForResponseWith(code: Int) -> StatusCode {
        switch code {
        case 200..<300:
            return .success
        case 401:
            return .unauthorized
        case 403:
            return .versionUnsupported
        case 500..<600:
            return .internalServerError
        default:
            return .undefined
        }
    }
}

class GetBaseService<Request: GetRequestDTOProtocol, Response: Decodable>: BaseService<Response> {
    
    fileprivate var request : URLRequest?

    func getRequest(requestDto :Request , responseDto:Response.Type , completion:@escaping(Result<Response>)->Void) -> URLSessionTask {
            let manager =  DataLoader()
            let url = makeUrl(url: requestDto.url, queryParmaters: requestDto.queryParameter.dictionary)
            let sessionTask = manager.responseGet(url) { (data, httpUrlResponse, error) in
            self.decodeResponse(data: data, response: httpUrlResponse as? HTTPURLResponse, error: error,responseDto:responseDto, completion: completion)
            print("request **** \(String(describing: self.request)) ****\n\n")
            }
        self.request = sessionTask.originalRequest
        return sessionTask

    }
    private func makeUrl(url:String , queryParmaters : [String : Any]?) -> String {
        if let query = queryParmaters , query.count > 0{
            var queryItems = [URLQueryItem]()
            for (key , value) in query {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
            var urlComps = URLComponents(string:url)!
            urlComps.queryItems = queryItems
            return "\(urlComps.url!)"
        }
        return url
        
    }
    
}


