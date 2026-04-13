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
    public static let shared = HTTPRequestUtility()
    
    // protect session instances with a serial queue
    private let sessionLock = DispatchQueue(label: "kr.co.koreabus.httprequestutility.session.lock")
    
    private let sessionDelegateForIgnoreSSLError = SessionDelegateForIgnoreSSLError()
    
    private var session: Session = Session()
    
    // use the stored delegate instance when creating the ignore-SSL session
    private var sessionIgnoreSSLError: Session = Session(delegate: SessionDelegateForIgnoreSSLError())
    
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
                          ignoreSSLError: Bool = true) -> Result<String, Error> {
        return requestSyncRaw(urlString,
                              method: method,
                              parameters: parameters,
                              body: body,
                              headers: headers,
                              encoding: encoding,
                              ignoreSSLError: ignoreSSLError)
            .map { $0.string }
    }
    
    // MARK: - Internal full-response method

    struct RawResponse {
        let string: String
        let headers: [AnyHashable: Any]
    }

    func requestSyncRaw(_ urlString: String,
                        method: String = "GET",
                        parameters: [String: Any]? = nil,
                        body: String? = nil,
                        headers: [String: String]? = nil,
                        encoding: String.Encoding = .utf8,
                        ignoreSSLError: Bool = true) -> Result<RawResponse, Error> {
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

        let resolvedHeaders = { () -> HTTPHeaders in
            var h = headers ?? [:]
            if let customUserAgent = customUserAgent {
                h["User-Agent"] = customUserAgent
            }
            return HTTPHeaders(h)
        }()

        let session: Session = sessionLock.sync { ignoreSSLError ? self.sessionIgnoreSSLError : self.session }

        session.sessionConfiguration.timeoutIntervalForRequest = 30
        session.sessionConfiguration.timeoutIntervalForResource = 60

        var dataRequest: DataRequest!
        if let body = body {
            do {
                var request = try URLRequest(url: url, method: method, headers: resolvedHeaders)
                request.httpBody = body.data(using: encoding)
                dataRequest = session.request(request)
            } catch {
                return .failure(error)
            }
        } else {
            dataRequest = session.request(urlString, method: method, parameters: parameters, headers: resolvedHeaders)
        }

        let semaphore = DispatchSemaphore(value: 0)
        var rawResponse: RawResponse?
        var responseError: Error?

        dataRequest.responseData(queue: DispatchQueue.global()) { response in
            switch response.result {
            case .success(let data):
                let string = String(data: data, encoding: encoding) ?? ""
                let headers = response.response?.allHeaderFields ?? [:]
                rawResponse = RawResponse(string: string, headers: headers)
            case .failure(let error):
                responseError = error
            }
            semaphore.signal()
        }

        semaphore.wait()

        if let rawResponse = rawResponse {
            return .success(rawResponse)
        }

        return .failure(responseError ?? NSError(
            domain: "\(HTTPRequestUtility.self)",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "HTTP response string is nil."]
        ))
    }

    // MARK : - SessionDelegate
    
    @objcMembers
    private final class SessionDelegateForIgnoreSSLError: SessionDelegate {
        // Session-level challenge (fallback)
        @objc(urlSession:didReceiveChallenge:completionHandler:)
        public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            acceptChallenge(challenge, completionHandler: completionHandler)
        }

        // Task-level challenge — Alamofire routes SSL errors here (NSURLErrorDomain -1202)
        @objc(URLSession:task:didReceiveChallenge:completionHandler:)
        public override func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            acceptChallenge(challenge, completionHandler: completionHandler)
        }

        private func acceptChallenge(_ challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
                  let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(.performDefaultHandling, nil)
                return
            }
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }
    
    // Recreate (invalidate + replace) Alamofire Session instances safely.
    public func recreateSessions() {
        sessionLock.sync {
            // finish outstanding tasks gracefully then invalidate backing URLSessions
            self.session.session.finishTasksAndInvalidate()
            self.sessionIgnoreSSLError.session.finishTasksAndInvalidate()

            // recreate new Alamofire Session instances using the stored delegate
            self.session = Session()
            self.sessionIgnoreSSLError = Session(delegate: self.sessionDelegateForIgnoreSSLError)
        }
    }
    
    // MARK: -
    
    public class Response<T> {
        public let value: T?
        public let error: Error?
        public let responseString: String?
        public let responseHeaders: [AnyHashable: Any]?

        public init(_ value: T, responseString: String? = nil, responseHeaders: [AnyHashable: Any]? = nil) {
            self.value = value
            self.error = nil
            self.responseString = responseString
            self.responseHeaders = responseHeaders
        }

        public init(_ error: Error, responseString: String? = nil, responseHeaders: [AnyHashable: Any]? = nil) {
            self.value = nil
            self.error = error
            self.responseString = responseString
            self.responseHeaders = responseHeaders
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
                         ignoreSSLError: Bool = true) -> HTTPRequestUtility.Response<T> {
        var method = method
        if parameters != nil { method = "POST" }
        if body != nil { method = "POST" }

        let result = HTTPRequestUtility.shared.requestSyncRaw(
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

        if case Result.success(let raw) = result {
            let responseString = raw.string
            let responseHeaders = raw.headers

            if T.self == String.self {
                return HTTPRequestUtility.Response(responseString as! T,
                                                   responseString: responseString,
                                                   responseHeaders: responseHeaders)
            } else if T.self == JSON.self {
                guard let json = responseString.asJSON() else {
                    return HTTPRequestUtility.Response(JSONError(),
                                                       responseString: responseString,
                                                       responseHeaders: responseHeaders)
                }
                return HTTPRequestUtility.Response(json as! T,
                                                   responseString: responseString,
                                                   responseHeaders: responseHeaders)
            } else if T.self == Document.self {
                do {
                    let document = try SwiftSoup.parse(responseString)
                    return HTTPRequestUtility.Response(document as! T,
                                                       responseString: responseString,
                                                       responseHeaders: responseHeaders)
                } catch {
                    return HTTPRequestUtility.Response(error,
                                                       responseString: responseString,
                                                       responseHeaders: responseHeaders)
                }
            }
        }

        return HTTPRequestUtility.Response(UnsupportedTypeError())
    }
}
