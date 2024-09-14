//
//  OrderModel.swift
//  songsurprise
//
//  Created by resoul on 12.09.2024.
//

struct OrderModel {
    let icon: String
    let title: String
    let description: String
    
    init(icon: String, title: String, description: String) {
        self.icon = icon
        self.title = title
        self.description = description
    }
}
