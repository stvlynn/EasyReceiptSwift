import Foundation

struct FeishuConfig {
    let apiKey: String
    let appToken: String
    let deliveryTableId: String
    let trainTableId: String
    let invoiceTableId: String
    
    static func load() -> FeishuConfig? {
        guard let apiKey = UserDefaults.standard.string(forKey: "FeishuAPIKey"),
              let appToken = UserDefaults.standard.string(forKey: "FeishuAppToken"),
              let deliveryTableId = UserDefaults.standard.string(forKey: "FeishuDeliveryTableId"),
              let trainTableId = UserDefaults.standard.string(forKey: "FeishuTrainTableId"),
              let invoiceTableId = UserDefaults.standard.string(forKey: "FeishuInvoiceTableId")
        else {
            return nil
        }
        return FeishuConfig(apiKey: apiKey, 
                          appToken: appToken, 
                          deliveryTableId: deliveryTableId,
                          trainTableId: trainTableId,
                          invoiceTableId: invoiceTableId)
    }
}

enum FeishuError: Error {
    case configurationMissing
    case invalidResponse
    case networkError(Error)
    case apiError(String)
}

class FeishuService {
    static let shared = FeishuService()
    private init() {}
    
    func submitReceipt(_ outputs: ReceiptOutputs) async throws {
        guard let config = FeishuConfig.load() else {
            throw FeishuError.configurationMissing
        }
        
        let url = URL(string: "https://open.feishu.cn/open-apis/bitable/v1/apps/\(config.appToken)/tables/\(config.deliveryTableId)/records/batch_create")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        
        let fields: [String: Any] = [
            "ProjectName": outputs.ProjectName,
            "AuditedEntity": outputs.AuditedEntity,
            "AuditedEntityPerson": outputs.AuditedEntityPerson,
            "AuditedEntityPhone": outputs.AuditedEntityPhone,
            "ReceivingEntity": outputs.ReceivingEntity,
            "Recipient": outputs.Recipient,
            "ReceivingEntityPhone": outputs.ReceivingEntityPhone,
            "FileName": outputs.FileName,
            "FileType": outputs.FileType,
            "FileNum": outputs.FileNum,
            "FileReceipient": outputs.FileReceipient,
            "HandOverDate": outputs.HandOverDate,
            "ReceivedDate": outputs.ReceivedDate
        ]
        
        let body: [String: Any] = [
            "records": [
                ["fields": fields]
            ]
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FeishuError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = errorResponse["msg"] as? String {
                throw FeishuError.apiError(msg)
            }
            throw FeishuError.apiError("HTTP \(httpResponse.statusCode)")
        }
    }

    func submitTrainTicket(_ outputs: TrainTicketOutputs) async throws {
        guard let config = FeishuConfig.load() else {
            throw FeishuError.configurationMissing
        }
        
        let url = URL(string: "https://open.feishu.cn/open-apis/bitable/v1/apps/\(config.appToken)/tables/\(config.trainTableId)/records/batch_create")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        
        let fields: [String: Any] = [
            "TrainNum": outputs.TrainNum,
            "DepartureDate": outputs.DepartureDate,
            "Departure": outputs.Departure,
            "Destination": outputs.Destination,
            "Price": outputs.Price,
            "ID": outputs.ID,
            "Name": outputs.Name
        ]
        
        let body: [String: Any] = [
            "records": [
                ["fields": fields]
            ]
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FeishuError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = errorResponse["msg"] as? String {
                throw FeishuError.apiError(msg)
            }
            throw FeishuError.apiError("HTTP \(httpResponse.statusCode)")
        }
    }
}
