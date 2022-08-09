//
//  CocktailAPI_Helper.swift
//  CocktailDb
//
//  Created by Kushal Vaghani on 30/07/2022.
//

import Foundation

class CocktailAPI_Helper{
    static var baseURL = "https://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Alcoholic"
    
    static var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    static func fetchCocktails() async throws -> [String : AnyObject] {
        guard
            let url = URL(string: baseURL)
        else{throw("Cannot convert baseURL to an actual URL" as! Error)}
        let request = URLRequest(url: url)
        let (data, _) = try await session.data(for: request)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        guard
            let jsonDictionary = jsonObject as? [AnyHashable: Any],
                let breeds = jsonDictionary as? [String:AnyObject]
        else {throw("could not parse data") as! Error}
        return breeds
    }
}

class CocktailDetail_Helper{
    static var baseURL = "https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i="
    
    static var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    static func fetchCocktailDetails(id: String) async throws -> [String : AnyObject]{
        guard
            let url = URL(string: baseURL + "\(id)")
        else{throw("Cannot convert baseURL to an actual URL" as! Error)}
        let request = URLRequest(url: url)
        let (data, _) = try await session.data(for: request)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        guard
            let jsonDictionary = jsonObject as? [AnyHashable: Any],
                let breeds = jsonDictionary as? [String:AnyObject]
        else {throw("could not parse data") as! Error}
        return breeds
    }
}
