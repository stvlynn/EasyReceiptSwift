import UIKit

class SettingsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // 设置项数据
    private let sections = ["Dify设置", "飞书设置"]
    private let settings: [[String: String]] = [
        ["Dify Base URL": "DifyAPIURL",
         "Dify API Key": "DifyAPIKey"],
        ["飞书 API Key": "FeishuAPIKey",
         "飞书 App Token": "FeishuAppToken",
         "签收单 Table ID": "FeishuDeliveryTableId",
         "火车票 Table ID": "FeishuTrainTableId",
         "电子发票 Table ID": "FeishuInvoiceTableId"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "设置"
        view.backgroundColor = .systemBackground
        
        // 设置tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingCell.self, forCellReuseIdentifier: "SettingCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
        let settingDict = settings[indexPath.section]
        let title = Array(settingDict.keys)[indexPath.row]
        let key = settingDict[title]!
        
        cell.configure(title: title, key: key)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let settingDict = settings[indexPath.section]
        let title = Array(settingDict.keys)[indexPath.row]
        let key = settingDict[title]!
        
        let detailVC = SettingDetailViewController(title: title, key: key)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - SettingCell
class SettingCell: UITableViewCell {
    private var key: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, key: String) {
        self.key = key
        textLabel?.text = title
        
        // 如果是密码类型的设置项，显示"已设置"或"未设置"
        if title.contains("Key") || title.contains("Token") {
            detailTextLabel?.text = UserDefaults.standard.string(forKey: key) != nil ? "已设置" : "未设置"
        } else {
            detailTextLabel?.text = UserDefaults.standard.string(forKey: key)
        }
    }
}

// MARK: - SettingDetailViewController
class SettingDetailViewController: UIViewController {
    private let settingTitle: String
    private let settingKey: String
    
    private let textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .done
        return field
    }()
    
    init(title: String, key: String) {
        self.settingTitle = title
        self.settingKey = key
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = settingTitle
        view.backgroundColor = .systemBackground
        
        // 添加保存按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存",
                                                          style: .done,
                                                          target: self,
                                                          action: #selector(saveSettings))
        
        // 设置文本框
        textField.placeholder = "请输入\(settingTitle)"
        if settingTitle.contains("Key") || settingTitle.contains("Token") {
            textField.isSecureTextEntry = true
        }
        textField.text = UserDefaults.standard.string(forKey: settingKey)
        textField.delegate = self
        
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 添加点击手势来收起键盘
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func saveSettings() {
        guard let text = textField.text, !text.isEmpty else {
            let alert = UIAlertController(title: "错误",
                                        message: "请输入内容",
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            return
        }
        
        UserDefaults.standard.set(text, forKey: settingKey)
        
        // 显示成功提示并返回
        let alert = UIAlertController(title: "成功",
                                    message: "设置已保存",
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension SettingDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
