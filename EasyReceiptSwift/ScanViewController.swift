import UIKit

class ScanViewController: UIViewController {
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var deliveryButton: UIButton = createButton(title: "签收单", systemImage: "box.truck.fill")
    private lazy var invoiceButton: UIButton = createButton(title: "电子发票", systemImage: "doc.text.fill")
    private lazy var trainTicketButton: UIButton = createButton(title: "火车票", systemImage: "train.side.front.car")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "识别"
        view.backgroundColor = .systemBackground
        
        view.addSubview(stackView)
        
        [deliveryButton, invoiceButton, trainTicketButton].forEach { button in
            stackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func createButton(title: String, systemImage: String) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.image = UIImage(systemName: systemImage)
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = .systemBlue
        configuration.cornerStyle = .medium
        
        let button = UIButton(configuration: configuration)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        switch sender {
        case deliveryButton:
            let deliveryVC = DeliveryReceiptViewController()
            navigationController?.pushViewController(deliveryVC, animated: true)
        case invoiceButton:
            print("电子发票扫描")
        case trainTicketButton:
            let trainTicketVC = TrainTicketViewController()
            navigationController?.pushViewController(trainTicketVC, animated: true)
        default:
            break
        }
    }
}
