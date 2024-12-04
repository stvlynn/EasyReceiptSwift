import Foundation

class DifyService {
    static let shared = DifyService()
    
    private init() {}
    
    var baseURL: String {
        return UserDefaults.standard.string(forKey: "DifyAPIURL") ?? "https://api.dify.ai/"
    }
    
    var apiKey: String {
        return UserDefaults.standard.string(forKey: "DifyAPIKey") ?? ""
    }
    
    func uploadImage(_ imageData: Data, filename: String) async throws -> String {
        let url = URL(string: baseURL.trimmingCharacters(in: ["/"]) + "/v1/files/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(UploadResponse.self, from: data)
        return response.id
    }
    
    func processDeliveryReceipt(fileId: String) async throws -> DeliveryReceiptResponse {
        let url = URL(string: baseURL.trimmingCharacters(in: ["/"]) + "/v1/workflows/run")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = WorkflowRequest(
            inputs: WorkflowInputs(
                file: FileInput(
                    transfer_method: "local_file",
                    upload_file_id: fileId,
                    type: "image"
                ),
                type: "DeliveryReceipt"
            ),
            response_mode: "blocking",
            user: "ios-user"
        )
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(DeliveryReceiptResponse.self, from: data)
    }
    
    func parseResponse(_ data: Data) throws -> ReceiptOutputs {
        let decoder = JSONDecoder()
        let response = try decoder.decode(DifyResponse.self, from: data)
        
        guard let answer = response.answer else {
            throw DifyError.noAnswer
        }
        
        // 解析JSON字符串为对象
        let jsonData = answer.data(using: .utf8)!
        let outputs = try decoder.decode(ReceiptOutputs.self, from: jsonData)
        
        // 验证日期格式
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        // 验证移交日期格式
        if dateFormatter.date(from: outputs.HandOverDate) == nil {
            throw DifyError.invalidDateFormat("HandOverDate格式错误，应为YYYY/MM/DD")
        }
        
        // 验证签收日期格式
        if dateFormatter.date(from: outputs.ReceivedDate) == nil {
            throw DifyError.invalidDateFormat("ReceivedDate格式错误，应为YYYY/MM/DD")
        }
        
        return outputs
    }
}

// Response Models
struct UploadResponse: Codable {
    let id: String
    let name: String
    let size: Int
    let extension_: String
    let mime_type: String
    let created_by: String
    let created_at: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, size
        case extension_ = "extension"
        case mime_type
        case created_by
        case created_at
    }
}

struct WorkflowRequest: Codable {
    let inputs: WorkflowInputs
    let response_mode: String
    let user: String
}

struct WorkflowInputs: Codable {
    let file: FileInput
    let type: String
}

struct FileInput: Codable {
    let transfer_method: String
    let upload_file_id: String
    let type: String
}

struct DeliveryReceiptResponse: Codable {
    let task_id: String
    let workflow_run_id: String
    let data: WorkflowData
}

struct WorkflowData: Codable {
    let id: String
    let workflow_id: String
    let status: String
    let outputs: ReceiptOutputs
    let error: String?
    let elapsed_time: Double
    let total_tokens: Int
    let total_steps: Int
    let created_at: Int
    let finished_at: Int
}

struct ReceiptOutputs: Codable {
    let ProjectName: String          // 项目名称 (String)
    let AuditedEntity: String       // 被审计单位 (String)
    let AuditedEntityPerson: String // 被审计单位移交人 (String)
    let AuditedEntityPhone: String  // 被审计单位联系电话 (String)
    let ReceivingEntity: String     // 签收单位 (String)
    let Recipient: String           // 签收人 (String)
    let ReceivingEntityPhone: String // 签收单位联系电话 (String)
    let FileName: String            // 文件名称 (String)
    let FileType: String           // 文件类型 (String)
    let FileNum: Int               // 文件份数 (Number)
    let FileReceipient: String     // 文件签收人 (String)
    let HandOverDate: String       // 移交日期 (String, YYYY/MM/DD)
    let ReceivedDate: String       // 签收日期 (String, YYYY/MM/DD)
}

struct DifyResponse: Codable {
    let answer: String?
}

enum DifyError: Error {
    case invalidResponse
    case noAnswer
    case invalidDateFormat(String)
    case networkError(Error)
}
