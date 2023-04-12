//
//  Utils.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 03/04/2023.
//

import Foundation
import SwaggerClient
import FirebaseFirestore

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

func addColorToGenre(){
    let baseColors = ["#CEB3E0", "#E5CDBE", "#D5B3E5", "#C1D5C7", "#A9C7E0", "#E5E4C1", "#E5BED1", "#D5B3A9", "#B3E5BE", "#B3D5E5", "#E5A9C1", "#B3E5A9", "#E0DCCD", "#BEBCE5", "#E5B3D5", "#F2DCC1", "#A9FFE5", "#E5CDBE", "#B39FDD", "#B3D5A9", "#BEC1E5", "#9FA9D5", "#F2B6B5", "#E5BEFF", "#A9C7FF", "#C7E5A9", "#B3E5B3", "#D6C1A9", "#E5B3E5", "#A9B3E5"]

    let lighterColors = ["#E6D4F2", "#F2E6E0", "#F1E6F2", "#E4F2E3", "#D4E6F1", "#F2F1E6", "#F2E0E6", "#F1E6D4", "#E6F2E0", "#E6F1F2", "#F2D4E6", "#E6F2D4", "#F4F1DE", "#E6E4F2", "#F2E6F1", "#F7E7CE", "#D4F2E6", "#F2E6E4", "#E6D4EF", "#E6F1D4", "#E0E6F2", "#D4F1E6", "#F7CAC9", "#E6E0F2", "#D4E6F2", "#E4F2E6", "#E6F2E6", "#EFE6D4", "#F2E6F2", "#E0E6F2"]
    
    let genresRef = Firestore.firestore().collection("genres")
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
    
}

