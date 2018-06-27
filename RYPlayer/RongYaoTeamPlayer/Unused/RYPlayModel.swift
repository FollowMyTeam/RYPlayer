//
//  RYPlayModel.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/25.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

// MARK: 待定, 模型暂不使用, 架构冲突

public protocol RYPlayModelViewProtocol: NSObjectProtocol {
    var tag: Int {get set}
}

/// - RongYaoTeamPlayer super view
///     - RongYaoTeamPlayer
open class RYPlayModel {
    
    init(_ asset: RongYaoTeamPlayerAsset) {
        self.asset = asset
    }
    
    let asset: RongYaoTeamPlayerAsset
}

/// - UITableView
///     - UITableViewCell
///         - RongYaoTeamPlayer super view
///             - RongYaoTeamPlayer
open class RYUITableViewCellPlayModel: RYPlayModel {
    init(asset: RongYaoTeamPlayerAsset, atIndexPath: IndexPath, superView: UIView & RYPlayModelViewProtocol, tableView: UITableView) {
        self.atIndexPath = atIndexPath
        self.superViewTag = superView.tag
        self.tableView = tableView
        super.init(asset)
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
    init(asset: RongYaoTeamPlayerAsset, atIndexPath: IndexPath, superView: UIView & RYPlayModelViewProtocol, collectionView: UICollectionView) {
        self.atIndexPath = atIndexPath
        self.superViewTag = superView.tag
        self.collectionView = collectionView
        super.init(asset)
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
    init(asset: RongYaoTeamPlayerAsset, superView: UIView, tableView: UITableView) {
        self.superView = superView
        self.tableView = tableView
        super.init(asset)
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
    init(asset: RongYaoTeamPlayerAsset, atIndexPath: IndexPath, superView: UIView & RYPlayModelViewProtocol, collectionView: UICollectionView & RYPlayModelViewProtocol, collectionViewIndexPath: IndexPath, tableView: UITableView) {
        self.atIndexPath = atIndexPath
        self.superViewTag = superView.tag
        self.collectionViewTag = collectionView.tag
        self.collectionViewIndexPath = collectionViewIndexPath
        self.tableView = tableView
        super.init(asset)
    }
    
    var atIndexPath: IndexPath
    var superViewTag: Int
    var collectionViewTag: Int
    var collectionViewIndexPath: IndexPath
    var tableView: UITableView
}
