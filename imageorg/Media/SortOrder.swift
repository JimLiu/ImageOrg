//
//  SortOrder.swift
//  imageorg
//
//  Created by Finn Schlenk on 09.01.19.
//  Copyright © 2019 Finn Schlenk. All rights reserved.
//

import Cocoa

enum SortOrder: CaseIterable {
    case createdAt
    case name
    case favorites

    var title: String {
        switch self {
        case .createdAt:
            return "Date"
        case .name:
            return "Name"
        case .favorites:
            return "Favorites"
        }
    }
}

protocol SortOrderMenuDelegate: class {
    func didSelect(sortOrder: SortOrder)
}

class SortOrderMenu: NSMenu {

    weak var customDelegate: SortOrderMenuDelegate?

    override init(title: String) {
        super.init(title: title)

        autoenablesItems = true

        let sortByDateItem = NSMenuItem(title: SortOrder.createdAt.title, action: #selector(sortByDate), keyEquivalent: "")
        let sortByNameItem = NSMenuItem(title: SortOrder.name.title, action: #selector(sortByName), keyEquivalent: "")
        let sortByFavoritesItem = NSMenuItem(title: SortOrder.favorites.title, action: #selector(sortByFavorites), keyEquivalent: "")
        sortByDateItem.target = self
        sortByNameItem.target = self
        sortByFavoritesItem.target = self

        addItem(sortByDateItem)
        addItem(sortByNameItem)
        addItem(sortByFavoritesItem)
    }

    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    @objc func sortByDate() {
        customDelegate?.didSelect(sortOrder: .createdAt)
        print("sort by date")
    }

    @objc func sortByName() {
        customDelegate?.didSelect(sortOrder: .name)
        print("sort by name")
    }

    @objc func sortByFavorites() {
        customDelegate?.didSelect(sortOrder: .favorites)
        print("sort by name")
    }
}
