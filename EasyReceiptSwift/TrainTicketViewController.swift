import UIKit
import PhotosUI

class TrainTicketViewController: UIViewController {
    private var imageView: UIImageView!
    private var captureButton: UIButton!
    private var submitButton: UIButton!
    private var loadingIndicator: UIActivityIndicatorView!
    private var resultView: UIStackView!
    private var selectedImage: UIImage?
    private var outputs: TrainTicketOutputs?
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    
    // 表单字段
    private var trainNumField: UITextField!          // 车次
    private var departureDateField: UITextField!    // 出发日期
    private var departureField: UITextField!        // 始发站
    private var destinationField: UITextField!      // 终点站
    private var priceField: UITextField!            // 票价
    private var nameField: UITextField!             // 姓名
    private var idField: UITextField!               // 身份证号
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "火车票识别"
        view.backgroundColor = .systemBackground
        
        // 创建滚动视图
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // 内容视图
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 图片预览
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        // 设置按钮样式
        captureButton = UIButton(type: .system)
        captureButton.setTitle("选择图片", for: .normal)
        captureButton.backgroundColor = .systemBlue
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.layer.cornerRadius = 12
        captureButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(captureButton)
        
        // 提交按钮
        submitButton = UIButton(type: .system)
        submitButton.setTitle("提交", for: .normal)
        submitButton.backgroundColor = .systemGreen
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 12
        submitButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.isHidden = true
        contentView.addSubview(submitButton)
        
        // Loading indicator
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        contentView.addSubview(loadingIndicator)
        
        // 结果视图
        resultView = UIStackView()
        resultView.axis = .vertical
        resultView.spacing = 16
        resultView.isHidden = true
        resultView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resultView)
        
        setupInputFields()
        
        // 设置约束
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.75),
            
            resultView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            resultView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            resultView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),
            
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            captureButton.widthAnchor.constraint(equalToConstant: 120),
            captureButton.heightAnchor.constraint(equalToConstant: 44),
            
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            submitButton.widthAnchor.constraint(equalToConstant: 120),
            submitButton.heightAnchor.constraint(equalToConstant: 44),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    private func setupInputFields() {
        // 创建所有输入字段
        trainNumField = createStyledTextField(placeholder: "车次")
        departureDateField = createStyledTextField(placeholder: "出发日期")
        departureField = createStyledTextField(placeholder: "出发站")
        destinationField = createStyledTextField(placeholder: "到达站")
        priceField = createStyledTextField(placeholder: "票价")
        nameField = createStyledTextField(placeholder: "姓名")
        idField = createStyledTextField(placeholder: "身份证号")
        
        // 将字段添加到结果视图
        [
            trainNumField, departureDateField, departureField,
            destinationField, priceField, nameField, idField
        ].forEach { field in
            let container = createFieldContainer(for: field)
            resultView.addArrangedSubview(container)
        }
    }
    
    private func createStyledTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 17)
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.rightViewMode = .always
        return textField
    }
    
    private func createFieldContainer(for textField: UITextField) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 12
        
        let label = UILabel()
        label.text = textField.placeholder
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        
        container.addSubview(label)
        container.addSubview(textField)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            textField.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }
    
    @objc private func imageViewTapped() {
        guard let image = imageView.image else { return }
        
        let fullScreenVC = TrainTicketFullScreenImageViewController(image: image)
        fullScreenVC.modalPresentationStyle = .fullScreen
        present(fullScreenVC, animated: true)
    }
    
    @objc private func captureButtonTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "拍照", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            })
        }
        
        actionSheet.addAction(UIAlertAction(title: "从相册选择", style: .default) { [weak self] _ in
            self?.presentPhotoPicker()
        })
        
        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func processImage(_ image: UIImage) {
        selectedImage = image
        imageView.image = image
        loadingIndicator.startAnimating()
        captureButton.isEnabled = false
        
        Task {
            do {
                guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
                }
                
                let filename = "train_ticket_\(Int(Date().timeIntervalSince1970)).jpg"
                let fileId = try await DifyService.shared.uploadImage(imageData, filename: filename)
                let response = try await DifyService.shared.processTrainTicket(fileId: fileId)
                
                await MainActor.run {
                    self.handleResponse(response.data.outputs)
                }
            } catch {
                await MainActor.run {
                    self.showError(error)
                }
            }
            
            await MainActor.run {
                self.loadingIndicator.stopAnimating()
                self.captureButton.isEnabled = true
            }
        }
    }
    
    private func handleResponse(_ outputs: TrainTicketOutputs) {
        self.outputs = outputs
        resultView.isHidden = false
        
        // 设置字符串类型的字段
        trainNumField.text = outputs.TrainNum
        departureDateField.text = outputs.DepartureDate
        departureField.text = outputs.Departure
        destinationField.text = outputs.Destination
        nameField.text = outputs.Name
        idField.text = outputs.ID
        
        // 设置数字类型的字段
        priceField.text = String(outputs.Price)
        
        // 更新UI状态
        captureButton.isHidden = true
        submitButton.isHidden = false
    }
    
    @objc private func submitButtonTapped() {
        loadingIndicator.startAnimating()
        submitButton.isEnabled = false
        
        Task {
            do {
                try await FeishuService.shared.submitTrainTicket(outputs!)
                
                // 提交成功后返回上一页
                DispatchQueue.main.async { [weak self] in
                    self?.loadingIndicator.stopAnimating()
                    self?.navigationController?.popViewController(animated: true)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.loadingIndicator.stopAnimating()
                    self?.submitButton.isEnabled = true
                    self?.showError(error)
                }
            }
        }
    }
    
    private func showError(_ error: Error) {
        loadingIndicator.stopAnimating()
        
        let message: String
        switch error {
        case FeishuError.configurationMissing:
            message = "请先在设置中配置飞书API信息"
        case FeishuError.invalidResponse:
            message = "飞书API响应格式错误"
        case FeishuError.apiError(let msg):
            message = "飞书API错误: \(msg)"
        case FeishuError.networkError(let networkError):
            message = "网络错误: \(networkError.localizedDescription)"
        case DifyError.invalidDateFormat(let details):
            message = details
        case DifyError.noAnswer:
            message = "无法获取识别结果"
        case DifyError.invalidResponse:
            message = "响应格式错误"
        case DifyError.networkError(let networkError):
            message = "网络错误: \(networkError.localizedDescription)"
        default:
            message = error.localizedDescription
        }
        
        let alert = UIAlertController(title: "错误",
                                    message: message,
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension TrainTicketViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            processImage(image)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension TrainTicketViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showError(error)
                }
                return
            }
            
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self?.processImage(image)
                }
            }
        }
    }
}

// MARK: - TrainTicketFullScreenImageViewController
class TrainTicketFullScreenImageViewController: UIViewController {
    private let imageView: UIImageView
    
    init(image: UIImage) {
        self.imageView = UIImageView(image: image)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("关闭", for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}
