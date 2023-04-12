//
//  Utils.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 03/04/2023.
//

import Foundation
import SwaggerClient

func removeHtmlTagsFromText(text: String)-> String{
    let regex = try! NSRegularExpression(pattern: "<[^>]+>", options: .caseInsensitive)
    let range = NSRange(text.startIndex..<text.endIndex, in: text)
    return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
}


func displayGenres(strings: [Genre]) -> String {
    var result = ""
    for (index, string) in strings.enumerated() {
        result += string.name ?? ""
        if index != strings.count - 1 {
            result += ", "
        }
    }
    return result
}

func displayAuthors(authors: [Author]) -> String {
    var stringNames = ""
    
    for (i, author) in authors.enumerated() {
        stringNames += (author.firstName ?? "") + " " + (author.lastName ?? "")
        if i != authors.count - 1 {
            stringNames += ", uuu"
        }
    }
    
    return stringNames
}
func secondsToMinutes(seconds: Int) -> Int{
    return seconds/60
}

func stringToColor(color: String) -> UIColor {
    guard let i = UInt(color, radix: 16) else {
        return UIColor.white
    }
    return UIColor(
        red: CGFloat((i & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((i & 0xFF00) >> 8) / 255.0,
        blue: CGFloat(i & 0xFF) / 255.0,
        alpha: 1.0
    )
}

/*
 Use to populate the main and secondary colors of each genre
 let baseColors = ["#8ED7F5", "#98DFF5", "#A2E7F5", "#ACEFF5", "#B6F7F5", "#C0FFF5", "#8FDB89", "#99E389", "#A3EB89", "#ADE389", "#B7F389", "#C1FB89", "#8A9A6E", "#949E6E", "#9EA26E", "#A8A66E", "#B2AA6E", "#BCAE6E", "#8E86B5", "#988AB5", "#A28FB5", "#AC93B5", "#B697B5", "#C09CB5", "#9D7B64", "#A57F64", "#AD8364", "#B58764", "#BD8B64", "#C58F64"]
 
 let lighterColors = ["#b8e4fa", "#c2edfa", "#ccf5fa", "#d6fdfa", "#e0fff9", "#e9fff9", "#bfe6a3", "#c9eba3", "#d3f0a3", "#ddf5a3", "#e7fba2", "#f0ffb0", "#a4b784", "#afb184", "#b9ba84", "#c3bf84", "#cdc484", "#d7c984", "#b298cc", "#bd9ccc", "#c7a1cc", "#d1a6cc", "#dbaacc", "#e5afcc", "#b27a4c", "#bc7e4c", "#c6814c", "#d0844c", "#da874c", "#e48b4c"]
 
 //let genresRef = Firestore.firestore().collection("genres")
 genresRef.getDocuments { querySnapshot, error in
 if let error = error {
 print("Error getting documents: \(error)")
 } else {
 let genres = querySnapshot!.documents
 for (index, genre) in genres.enumerated() {
 let mainColor = baseColors[index]
 let secondaryColor = lighterColors[index]
 genresRef.document(genre.documentID).updateData([
 "mainColor": mainColor,
 "secondaryColor": secondaryColor
 ]) { error in
 if let error = error {
 print("Error updating genre document: \(error)")
 } else {
 print("Genre document updated successfully")
 }
 }
 }
 }
 }
 */
