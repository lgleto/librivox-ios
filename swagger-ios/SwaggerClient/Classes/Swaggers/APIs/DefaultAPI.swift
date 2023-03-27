//
// DefaultAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import Alamofire


open class DefaultAPI {
    /**
     Finds Pets by status

     - parameter format: (query)  (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func rootGet(format: String? = nil, completion: @escaping ((_ data: BooksResponse?,_ error: Error?) -> Void)) {
        rootGetWithRequestBuilder(format: format).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Finds Pets by status
     - GET /

     - examples: [{contentType=application/json, example={
  "books" : [ {
    "url_project" : "url_project",
    "url_rss" : "url_rss",
    "totaltime" : "totaltime",
    "totaltimesecs" : 0,
    "language" : "language",
    "url_librivox" : "url_librivox",
    "id" : "id",
    "title" : "title",
    "authors" : [ {
      "last_name" : "last_name",
      "id" : "id",
      "first_name" : "first_name"
    }, {
      "last_name" : "last_name",
      "id" : "id",
      "first_name" : "first_name"
    } ]
  }, {
    "url_project" : "url_project",
    "url_rss" : "url_rss",
    "totaltime" : "totaltime",
    "totaltimesecs" : 0,
    "language" : "language",
    "url_librivox" : "url_librivox",
    "id" : "id",
    "title" : "title",
    "authors" : [ {
      "last_name" : "last_name",
      "id" : "id",
      "first_name" : "first_name"
    }, {
      "last_name" : "last_name",
      "id" : "id",
      "first_name" : "first_name"
    } ]
  } ]
}}]
     - parameter format: (query)  (optional)

     - returns: RequestBuilder<BooksResponse> 
     */
    open class func rootGetWithRequestBuilder(format: String? = nil) -> RequestBuilder<BooksResponse> {
        let path = "/"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
                        "format": format
        ])


        let requestBuilder: RequestBuilder<BooksResponse>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
}