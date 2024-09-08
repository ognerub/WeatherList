import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError
    case urlSessionError
    case errorDublicate
    case errorName
}
