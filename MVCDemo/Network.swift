//
//  Network.swift
//  NearGroup
//
//  Created by Manu Singh on 14/06/19.
//  Copyright © 2019 Manu Singh. All rights reserved.
//

import Foundation

class Network {
    
    fileprivate func generateBoundary()->String{
        
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var boundary = "-------"
        boundary += String((0..<35).map{ _ in letters.randomElement()! })
        boundary += "--------"
        return boundary
        
    }
}

protocol HTTPNetwork {
    func sendGetRequest(requestData : NetworkRequestData, completion : @escaping (Error?,Any?)->Void)
    func sendPostRequest(requestData : NetworkRequestData, completion : @escaping (Error?,Any?)->Void)
    func sendMultipartRequest(requestData : NetworkRequestData, completion : @escaping (Error?,Any?)->Void)
}

extension HTTPNetwork {
    func getData(from url : String,end : String, with parameters : [String:Any], completion : @escaping (Error?,Any?)->Void){
        let requestData = RequestData(url: url, end: end, parameters: parameters, headers: [:], files: [])
        sendPostRequest(requestData: requestData, completion: completion)
    }
}

extension Network : HTTPNetwork {
    
    func sendGetRequest(requestData : NetworkRequestData, completion : @escaping (Error?,Any?)->Void){
        guard var urlRequest = getUrlGETRequest(requestData: requestData) else { return }
        urlRequest.setRequestHeaders(headers: requestData.headers)
        sendHttpUrlRequest(urlRequest: urlRequest) { (error, data,response) in
            self.handleServerResponse(data: data, error: error, requestData: requestData, urlResponse: response, completion: completion)
        }
        
    }
    
    func sendPostRequest(requestData : NetworkRequestData, completion : @escaping (Error?,Any?)->Void){
        var urlRequest = getUrlPostRequest(requestData: requestData)
        urlRequest.setPostRequestBody(parameters: requestData.parameters)
        urlRequest.setRequestHeaders(headers: requestData.headers)
        sendHttpUrlRequest(urlRequest: urlRequest) { (error, data, response) in
            self.handleServerResponse(data: data, error: error, requestData: requestData, urlResponse: response, completion: completion)
        }
    }
    
    func sendMultipartRequest(requestData : NetworkRequestData, completion : @escaping (Error?,Any?)->Void){
        let boundary = generateBoundary()
        var urlRequest = getUrlPostRequest(requestData: requestData)
        urlRequest.setMultipartRequestBody(requestData: requestData, boundary: boundary)
        urlRequest.setMultipartRequestHeaders(headers: requestData.headers, boundary: boundary)
        sendHttpUrlRequest(urlRequest: urlRequest) { (error, data, response) in
            self.handleServerResponse(data: data, error: error, requestData: requestData, urlResponse: response, completion: completion)
        }
    }
    
    fileprivate func getUrlPostRequest(requestData : NetworkRequestData)->URLRequest{
        let fullUrl = "\(requestData.url)/\(requestData.endPoint)"
        print(fullUrl)
        var urlRequest = URLRequest(url: URL(string: fullUrl)!)
        urlRequest.httpMethod  =  "POST"
        return urlRequest
    }
    
    fileprivate func getUrlGETRequest(requestData : NetworkRequestData)->URLRequest?{
        var fullUrl = "\(requestData.url)/\(requestData.endPoint)"
        fullUrl.setUrlParameters(requestData.parameters)
        print(fullUrl)
        guard let properUrl = URL(string: fullUrl) else {
            return nil
        }
        var urlRequest = URLRequest(url: properUrl)
        urlRequest.httpMethod  =  "GET"
        return urlRequest
    }
    
    fileprivate func sendHttpUrlRequest(urlRequest : URLRequest,completion : @escaping (Error?, Data?,URLResponse?)->Void){
        let task =  URLSession.shared.dataTask(with: urlRequest, completionHandler: {
            data, response, error in
            completion(error,data, response)
        })
        task.resume()
    }
    
    fileprivate func handleServerResponse(data : Data?, error:Error? ,requestData :NetworkRequestData,urlResponse : URLResponse? ,completion :  @escaping (Error?, Any?)->Void){
        guard error == nil else {
            DispatchQueue.main.async {
                completion((error),nil)
            }
            return
        }
        
        if let jsonObject = data?.getSerializedObject() {
            DispatchQueue.main.async {
                completion(nil,jsonObject)
            }
        } else {
            DispatchQueue.main.async {
                let dataString = String(data: data!, encoding: String.Encoding.utf8)
                print(dataString ?? "")
                completion(nil,dataString)
            }
            
        }
        
    }
}


protocol NetworkRequestData {
    
    var url : String {get set}
    var endPoint : String {get set}
    var parameters : [String:Any] { get set }
    var headers : [String:String] { get set }
    var files : [[String:Any]] { get set }
}


public class RequestData : NetworkRequestData {
    
    let imageBucket = "ng-image"
    let mimeKey = "mime"
    let fileNameKey = "filename"
    let contentKey = "content"
    let imageNameKey = "imagekey"
    
    public var url : String
    public var endPoint : String
    public var parameters : [String:Any]
    public var headers : [String:String]
    public var files : [[String:Any]]
    
    public init(url : String,end : String,parameters : [String:Any],headers : [String:String],files:[[String:Any]]){
        self.url = url
        self.endPoint = end
        self.parameters = parameters
        self.headers = headers
        self.files = files
    }
   
    func getImageSaveParameters(playerId : String)->[String:Any]{
          let parameters : [String:Any] = [
              "bucket":imageBucket,
              "key":"profile_\(playerId)",
          ]
          return parameters
      }
    func getImagesFormatted(image : Data,playerId : String)->[[String:Any]]{
          let images : [String:Any] = [mimeKey:"image/jpeg",imageNameKey:"file",fileNameKey:"profile_\(playerId).jpg",contentKey:image]
          print(images)
          return [images]
      }
}

extension URLRequest {
    
    mutating func setPostRequestBody(parameters : [String:Any]){
        print(parameters)
        do {
            self.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    mutating func setMultipartRequestBody(requestData : NetworkRequestData,boundary : String){
        httpBody  =  createBodyWithParameters(parameters: requestData.parameters, files: requestData.files, boundary: boundary) as Data
    }
    
    mutating func setRequestHeaders(headers : [String:String]){
        self.addValue("application/json", forHTTPHeaderField: "Content-Type")
        setHeaders(headers: headers)
    }
    
    mutating func setMultipartRequestHeaders(headers : [String:String],boundary : String){
        setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        setValue("\(httpBody!.count)", forHTTPHeaderField:"Content-Length")
        setHeaders(headers: headers)
    }
    
    mutating func setHeaders(headers : [String:String]){
        self.addValue("application/json", forHTTPHeaderField: "Accept")
        for header in headers {
            self.addValue(header.value, forHTTPHeaderField: header.key)
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        self.addValue(appVersion, forHTTPHeaderField: "Version-Code")
        print(headers)
    }
    
}

extension Data {
    
    func getSerializedObject()->Any?{
        do {
            let jsonDict  = try JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.allowFragments)
            print(jsonDict)
            return jsonDict
    
        } catch {
            let dataString = String(data: self, encoding: String.Encoding.utf8)
            print(dataString ?? "")
        }
        return nil
    }
}

extension URLRequest {
    fileprivate func appendFiles(files:[[String:Any]],body : NSMutableData){
        
        for fileData in files {
            body.append("Content-Disposition:form-data; name=\"\(fileData["imagekey"] ?? "")\"; filename=\"\(fileData["filename"] ?? "")\"\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Type: \(fileData["mime"] ?? "")\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append(fileData["content"] as! Data)
            body.append("\r\n".data(using: String.Encoding.utf8)!)
        }
    }
    
    fileprivate func createBodyWithParameters(parameters: [String: Any],files:[[String:Any]], boundary: String) -> NSData {
        let body = NSMutableData()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
        }
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        appendFiles(files: files, body: body)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        return body
    }
}

extension String {
    
    mutating func setUrlParameters(_ parameters : [String:Any]){
        guard !parameters.isEmpty else { return }
        
        self += "?"
        for (key,value) in parameters {
            self.append("\(key)=\(value)&")
        }
        self = String(self.dropLast(1))
    }
    
}

