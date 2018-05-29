
//
//  HTTPStatusCodes.swift
//
//  Created by Richard Hodgkins on 11/01/2015.
//  Copyright (c) 2015 Richard Hodgkins. All rights reserved.
//

import Foundation

/**
 HTTP status codes as per http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
 
 The RF2616 standard is completely covered (http://www.ietf.org/rfc/rfc2616.txt)
 */
@objc public enum HTTPStatusCode: Int {
    // Informational
    case `continue` = 100
    case switchingProtocols = 101
    case processing = 102
    
    // Success
    case ok = 200
    case created = 201
    case accepted = 202
    case nonAuthoritativeInformation = 203
    case noContent = 204
    case resetContent = 205
    case partialContent = 206
    case multiStatus = 207
    case alreadyReported = 208
    case imUsed = 226
    
    // Redirections
    case multipleChoices = 300
    case movedPermanently = 301
    case found = 302
    case seeOther = 303
    case notModified = 304
    case useProxy = 305
    case switchProxy = 306
    case temporaryRedirect = 307
    case permanentRedirect = 308
    
    // Client Errors
    case badRequest = 400
    case unauthorized = 401
    case paymentRequired = 402
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case proxyAuthenticationRequired = 407
    case requestTimeout = 408
    case conflict = 409
    case gone = 410
    case lengthRequired = 411
    case preconditionFailed = 412
    case requestEntityTooLarge = 413
    case requestURITooLong = 414
    case unsupportedMediaType = 415
    case requestedRangeNotSatisfiable = 416
    case expectationFailed = 417
    case imATeapot = 418
    case authenticationTimeout = 419
    case unprocessableEntity = 422
    case locked = 423
    case failedDependency = 424
    case upgradeRequired = 426
    case preconditionRequired = 428
    case tooManyRequests = 429
    case requestHeaderFieldsTooLarge = 431
    case loginTimeout = 440
    case noResponse = 444
    case retryWith = 449
    case unavailableForLegalReasons = 451
    case requestHeaderTooLarge = 494
    case certError = 495
    case noCert = 496
    case httpToHTTPS = 497
    case tokenExpired = 498
    case clientClosedRequest = 499
    
    // Server Errors
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504
    case httpVersionNotSupported = 505
    case variantAlsoNegotiates = 506
    case insufficientStorage = 507
    case loopDetected = 508
    case bandwidthLimitExceeded = 509
    case notExtended = 510
    case networkAuthenticationRequired = 511
    case networkTimeoutError = 599
}

public extension HTTPStatusCode {
    /// Informational - Request received, continuing process.
    public var isInformational: Bool {
        return inRange(100...199)
    }
    /// Success - The action was successfully received, understood, and accepted.
    public var isSuccess: Bool {
        return inRange(200...299)
    }
    /// Redirection - Further action must be taken in order to complete the request.
    public var isRedirection: Bool {
        return inRange(300...399)
    }
    /// Client Error - The request contains bad syntax or cannot be fulfilled.
    public var isClientError: Bool {
        return inRange(400...499)
    }
    /// Server Error - The server failed to fulfill an apparently valid request.
    public var isServerError: Bool {
        return inRange(500...599)
    }
    
    /// - returns: `true` if the status code is in the provided range, false otherwise.
    fileprivate func inRange(_ range: CountableClosedRange<Int>) -> Bool {
        return range.contains(rawValue)
    }
}

public extension HTTPStatusCode {
    /// - returns: a localized string suitable for displaying to users that describes the specified status code.
    public var localizedReasonPhrase: String {
        return HTTPURLResponse.localizedString(forStatusCode: rawValue)
    }
}

// MARK: - Printing

extension HTTPStatusCode: CustomDebugStringConvertible, CustomStringConvertible {
    public var description: String {
        return "\(rawValue) - \(localizedReasonPhrase)"
    }
    public var debugDescription: String {
        return "HTTPStatusCode:\(description)"
    }
}

// MARK: - HTTP URL Response

public extension HTTPStatusCode {
    /// Obtains a possible status code from an optional HTTP URL response.
    public init?(HTTPResponse: HTTPURLResponse?) {
        if let value = HTTPResponse?.statusCode {
            self.init(rawValue: value)
        } else {
            return nil
        }
    }
}

public extension HTTPURLResponse {
    
    /**
     * Marked internal to expose (as `statusCodeValue`) for Objective-C interoperability only.
     *
     * - returns: the receiver’s HTTP status code.
     */
    @objc(statusCodeValue) var statusCodeEnum: HTTPStatusCode {
        return HTTPStatusCode(HTTPResponse: self)!
    }
    
    /// - returns: the receiver’s HTTP status code.
    public var statusCodeValue: HTTPStatusCode? {
        return HTTPStatusCode(HTTPResponse: self)
    }
    
    /**
     * Initializer for NSHTTPURLResponse objects.
     *
     * - parameter url: the URL from which the response was generated.
     * - parameter statusCode: an HTTP status code.
     * - parameter HTTPVersion: the version of the HTTP response as represented by the server.  This is typically represented as "HTTP/1.1".
     * - parameter headerFields: a dictionary representing the header keys and values of the server response.
     *
     * - returns: the instance of the object, or `nil` if an error occurred during initialization.
     */
    @available(iOS, introduced: 7.0)
    @objc(initWithURL:statusCodeValue:HTTPVersion:headerFields:)
    public convenience init?(URL url: URL, statusCode: HTTPStatusCode, HTTPVersion: String?, headerFields: [String : String]?) {
        self.init(url: url, statusCode: statusCode.rawValue, httpVersion: HTTPVersion, headerFields: headerFields)
    }
}
