//
//  iTunesTabBar.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/11/24.
//

import UIKit

class iTunesTabBar: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let todayVC = TodayViewController()
        let gameVC = GameViewController()
        let appVC = AppViewController()
        let arcadeVC = ArcadeViewController()
        let detailVC = iTunesSearchViewController()
        
        todayVC.tabBarItem.image = UIImage(systemName: "book")
        todayVC.tabBarItem.title = "투데이"
        gameVC.tabBarItem.image = UIImage(systemName: "gamecontroller")
        gameVC.tabBarItem.title = "게임"
        appVC.tabBarItem.image = UIImage(systemName: "square.stack.fill")
        appVC.tabBarItem.title = "앱"
        arcadeVC.tabBarItem.image = UIImage(systemName: "star")
        arcadeVC.tabBarItem.title = "아케이드"
        detailVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        detailVC.tabBarItem.title = "검색"

        let navToday = UINavigationController(rootViewController: todayVC)
        let navGame = UINavigationController(rootViewController: gameVC)
        let navApp = UINavigationController(rootViewController: appVC)
        let navArcade = UINavigationController(rootViewController: arcadeVC)
        let navDetail = UINavigationController(rootViewController: detailVC)
        
        setViewControllers([navToday,navGame,navApp,navArcade,navDetail,BoxOfficeViewController()], animated: true)

    }
}
