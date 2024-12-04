import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBar()
    }
    
    private func setupTabBar() {
        // 设置tab栏不透明
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .systemBlue
    }
    
    private func setupViewControllers() {
        let scanVC = ScanViewController()
        scanVC.tabBarItem = UITabBarItem(title: "识别", image: UIImage(systemName: "doc.text.viewfinder"), tag: 0)
        
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(title: "设置", image: UIImage(systemName: "gear"), tag: 1)
        
        viewControllers = [UINavigationController(rootViewController: scanVC),
                         UINavigationController(rootViewController: settingsVC)]
    }
}
