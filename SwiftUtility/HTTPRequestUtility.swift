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
import SwiftSoup

open class HTTPRequestUtility {
    static let shared = HTTPRequestUtility()
	
	private lazy var session = { () -> Session in
		return Session()
	}()
	
	private lazy var sessionIgnoreSSLError = { () -> Session in
		return Session(delegate: self.sessionDelegateForIgnoreSSLError)
	}()
	
	private let sessionDelegateForIgnoreSSLError = SessionDelegateForIgnoreSSLError()
    
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
    
    // swiftlint:disable function_body_length
    open func requestSync(_ urlString: String,
                          method: String = "GET",
                          parameters: [String: Any]? = nil,
                          body: String? = nil,
                          headers: [String: String]? = nil,
                          encoding: String.Encoding = .utf8,
						  ignoreSSLError: Bool = false) -> Result<String, Error> {
        var urlString = urlString
        
        let method = HTTPMethod(rawValue: method)
        
        if method == .get, let parameters = parameters {
            let query = parameters.compactMap({ key, value -> String in
                let value = "\(value)"
                return "\(key.urlEncoded)=\(value.urlEncoded)"
            }).joined(separator: "&")
            urlString += "?\(query)"
        }
        
        guard let url = URL(string: urlString) else {
            return .failure(MalformedURLError())
        }
        
        let headers = { () -> HTTPHeaders in
            var headers = headers ?? [:]
            if let customUserAgent = customUserAgent {
                headers["User-Agent"] = customUserAgent
            }
            return HTTPHeaders(headers)
        }()
		
		let session =
			ignoreSSLError
				? self.sessionIgnoreSSLError
				: self.session
		
		session.sessionConfiguration.timeoutIntervalForRequest = 30
		session.sessionConfiguration.timeoutIntervalForResource = 60
        
        var dataRequest: DataRequest!
        if let body = body {
            do {
                var request = try URLRequest(url: url, method: method, headers: headers)
                request.httpBody = body.data(using: encoding)
				dataRequest = session.request(request)
            } catch {
                return .failure(error)
            }
        } else {
            dataRequest = session.request(urlString, method: method, parameters: parameters, headers: headers)
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var responseString: String?
        var responseError: Error?
        dataRequest.responseData { response in
            switch response.result {
            case .success(let data):
                responseString = String(data: data, encoding: encoding)
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
	
	// MARK : - SessionDelegate
	
	private class SessionDelegateForIgnoreSSLError: SessionDelegate {
		public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
			completionHandler(
				.useCredential,
				URLCredential(trust: challenge.protectionSpace.serverTrust!)
			)
		}
	}
	
	// MARK: -
    
    public class Response<T> {
        public let value: T?
        public let error: Error?
        
        public init(_ value: T) {
            self.value = value
            self.error = nil
        }
        
        public init(_ error: Error) {
            self.value = nil
            self.error = error
        }
    }
}

// swiftlint:disable force_cast
public extension String {
    func requestAsURLAsync<T>(type: T.Type,
                              parameters: [String: Any]? = nil,
                              body: String? = nil,
                              headers: [String: String]? = nil,
                              encoding: String.Encoding = .utf8,
                              completion: ((HTTPRequestUtility.Response<T>) -> Void)? = nil) {
        DispatchQueue.global().async {
            let response = self.requestAsURL(type: type,
                                             parameters: parameters,
                                             body: body,
                                             headers: headers,
                                             encoding: encoding)
            DispatchQueue.main.async { completion?(response) }
        }
    }
    
    func requestAsURL<T>(type: T.Type,
                         method: String? = nil,
                         parameters: [String: Any]? = nil,
                         body: String? = nil,
                         headers: [String: String]? = nil,
                         encoding: String.Encoding = .utf8,
                         ignoreSSLError: Bool = false) -> HTTPRequestUtility.Response<T> {
        var method = method
        if parameters != nil { method = "POST" }
        if body != nil { method = "POST" }
        
        let result = HTTPRequestUtility.shared.requestSync(
            self,
            method: method ?? "GET",
            parameters: parameters,
            body: body,
            headers: headers,
            encoding: encoding,
			ignoreSSLError: ignoreSSLError
        )
        
        if case Result.failure(let error) = result {
            return HTTPRequestUtility.Response(error)
        }
        
        if case Result.success(let responseString) = result {
            if T.self == String.self {
                return HTTPRequestUtility.Response(responseString as! T)
            } else if T.self == JSON.self {
                guard let json = responseString.asJSON() else {
                    return HTTPRequestUtility.Response(JSONError())
                }
                return HTTPRequestUtility.Response(json as! T)
            } else if T.self == Document.self {
                do {
                    let document = try SwiftSoup.parse(responseString)
                    return HTTPRequestUtility.Response(document as! T)
                } catch {
                    return HTTPRequestUtility.Response(error)
                }
            }
        }
        
        return HTTPRequestUtility.Response(UnsupportedTypeError())
    }
}
