//
//  HTTPRequestUtility.swift
//  SwiftUtility
//
//  Created by Hank.Lee on 12/03/2020.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

open class HTTPRequestUtility {
    static let shared = HTTPRequestUtility()
    
    open var customUserAgent: String?
    
    open func requestGetSync(_ urlString: String,
                             parameters: [String: Any]? = nil,
                             headers: [String: String]? = nil,
                             encoding: String.Encoding = .utf8) -> Result<String, Error> {
        return requestSync(urlString,
                           method: "GET",
                           parameters: parameters,
                           headers: headers,
                           encoding: encoding)
    }
    
    open func requestSync(_ urlString: String,
                          method: String = "GET",
                          parameters: [String: Any]? = nil,
                          headers: [String: String]? = nil,
                          encoding: String.Encoding = .utf8) -> Result<String, Error> {
        var urlString = urlString
        let method = HTTPMethod(rawValue: method)
        
        if method == .get, let parameters = parameters {
            let query = parameters.compactMap({ key, value -> String in
                let value = "\(value)"
                return "\(key.urlEncoded)=\(value.urlEncoded)"
            }).joined(separator: "&")
            urlString += "?\(query)"
        }
        
        let headers = { () -> HTTPHeaders in
            var headers = headers ?? [:]
            if let customUserAgent = customUserAgent {
                headers["User-Agent"] = customUserAgent
            }
            return HTTPHeaders(headers)
        }()
        
        let semaphore = DispatchSemaphore(value: 0)
        let request = AF.request(urlString, method: method, parameters: parameters, headers: headers)
        var responseString: String?
        var responseError: Error?
        request.responseString(queue: .global()) { response in
            switch response.result {
            case .success(let string):
                responseString = string
            case .failure(let error):
                responseError = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        
        if let responseString = responseString {
            return .success(responseString)
        }
        
        return .failure(responseError ?? NSError(
            domain: "\(HTTPRequestUtility.self)",
            code: 0,
            userInfo: [
                NSLocalizedDescriptionKey: "HTTP response string is nil."
        ]))
    }
    
    public class Response<T> {
        public let value: T?
        public let error: Error?
        public init(value: T? = nil, error: Error? = nil) {
            self.value = value
            self.error = error
        }
    }
}

// swiftlint:disable force_cast
public extension String {
    func requestAsURL<T>(type: T.Type,
                         parameters: [String: Any]? = nil,
                         encoding: String.Encoding = .utf8) -> HTTPRequestUtility.Response<T> {
        let result = HTTPRequestUtility.shared.requestSync(
            self,
            method: ((parameters == nil) ? "GET" : "POST"),
            parameters: parameters,
            encoding: encoding
        )
        
        if case Result.failure(let error) = result {
            return HTTPRequestUtility.Response(error: error)
        }
        
        if case Result.success(let responseString) = result {
            if T.self == String.self {
                return HTTPRequestUtility.Response(value: (responseString as! T))
            } else if T.self == JSON.self {
                guard let json = responseString.asJSON(encoding: encoding) else {
                    return HTTPRequestUtility.Response(error: NSError(
                        domain: "\(HTTPRequestUtility.self)",
                        code: 0,
                        userInfo: [
                            NSLocalizedDescriptionKey: "response string to JSON failed."
                    ]))
                }
                return HTTPRequestUtility.Response(value: (json as! T))
            }
        }
        
        return HTTPRequestUtility.Response(error: NSError(
            domain: "\(HTTPRequestUtility.self)",
            code: 0,
            userInfo: [
                NSLocalizedDescriptionKey: "expected result type is not supported."
        ]))
    }
}
