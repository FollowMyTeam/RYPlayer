//
//  RYPlayModel.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit


/// 该模型稍有不妥, 得重新整理架构

public protocol RYPlayModelViewProtocol: NSObjectProtocol {
    var tag: Int {get set}
}

/// - RongYaoTeamPlayer super view
///     - RongYaoTeamPlayer
open class RYPlayModel: NSObject {
    
    init(URL: URL) {
        self.URL = URL
        super.init()
    }
    
    let URL: URL
}

/// - UITableView
///     - UITableViewCell
///         - RongYaoTeamPlayer super view
///             - RongYaoTeamPlayer
open class RYUITableViewCellPlayModel: RYPlayModel {
    init(URL: URL, atIndexPath: IndexPath, superView: UIView & RYPlayModelViewProtocol, tableView: UITableView) {
        self.atIndexPath = atIndexPath
        self.superViewTag = superView.tag
        self.tableView = tableView
        super.init(URL: URL)
    }
    
    var atIndexPath: IndexPath
    var superViewTag: Int
    var tableView: UITableView
}

/// - UICollectionView
///     - UICollectionViewCell
///         - RongYaoTeamPlayer super view
///             - RongYaoTeamPlayer
open class RYUICollectionViewCellPlayModel: RYPlayModel {
    init(URL: URL, atIndexPath: IndexPath, superView: UIView & RYPlayModelViewProtocol, collectionView: UICollectionView) {
        self.atIndexPath = atIndexPath
        self.superViewTag = superView.tag
        self.collectionView = collectionView
        super.init(URL: URL)
    }
    
    var atIndexPath: IndexPath
    var superViewTag: Int
    var collectionView: UICollectionView
}

/// - UITableView
///     - UITableViewHeaderView
///         - RongYaoTeamPlayer super view
///             - RongYaoTeamPlayer
open class RYUITableHeaderViewPlayModel: RYPlayModel {
    init(URL: URL, superView: UIView, tableView: UITableView) {
        self.superView = superView
        self.tableView = tableView
        super.init(URL: URL)
    }
    
    var superView: UIView
    var tableView: UITableView
}

/// - UITableView
///     - UITableViewCell
///         - UICollectionView
///             - UICollectionViewCell
///                 - RongYaoTeamPlayer super view
///                     - RongYaoTeamPlayer
open class RYNestedPlayModel: RYPlayModel {
    init(URL: URL, atIndexPath: IndexPath, superView: UIView & RYPlayModelViewProtocol, collectionView: UICollectionView & RYPlayModelViewProtocol, collectionViewIndexPath: IndexPath, tableView: UITableView) {
        self.atIndexPath = atIndexPath
        self.superViewTag = superView.tag
        self.collectionViewTag = collectionView.tag
        self.collectionViewIndexPath = collectionViewIndexPath
        self.tableView = tableView
        super.init(URL: URL)
    }
    
    var atIndexPath: IndexPath
    var superViewTag: Int
    var collectionViewTag: Int
    var collectionViewIndexPath: IndexPath
    var tableView: UITableView
}
