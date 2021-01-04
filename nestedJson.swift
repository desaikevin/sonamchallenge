import Foundation


struct responder: Codable {
    let data: [data]
    let total: Int
    let perPage: Int
    let page: String

    private enum CodingKeys: String, CodingKey {
        case data
        case total
        case page
        case perPage = "per_page"
    }
}

struct data: Codable {
    var id: Int
    var timestamp: Int
    var status: String
    let operatingParams: operatingParams
    var rotorSpeed: Int?

    private enum CodingKeys: String, CodingKey {
        case id
        case status
        case timestamp
        case operatingParams
        case rotorSpeed
    }
}

struct operatingParams: Codable {
    let rotorSpeed: Double
    let slack: Double
    let rootThreshold: Float

    private enum CodingKeys: String, CodingKey {
        case rotorSpeed
        case slack
        case rootThreshold
    }
}

func getRequest(site: String, completion: @escaping (responder?, Error?) -> Void) {
    let url = URL(string: site)
    var request = URLRequest(url: url!)
    let session = URLSession.shared
    request.httpMethod = "GET"
    request.timeoutInterval = 30
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    let task = session.dataTask(with: request) { (data, response, error) in
        guard error == nil else {
            print("error \(String(describing: error))")
            return }
        if let resp = response as? HTTPURLResponse {
            switch resp.statusCode {
                case 200:
                    if let data = data {
                        print("Received 200")
                        let decoder = JSONDecoder()
                        let info = try? decoder.decode(responder.self, from: data)
                            completion(info, nil)
                        }
                default:
                    print("Invalid status received \(resp.statusCode)")
                    completion(nil, error)

            }
        }
    }
    task.resume()
}



let website = "https://jsonmock.hackerrank.com/api/iot_devices/search?status=STOP&page=2"

let result = getRequest(site: website) { (result, err) in
    guard err == nil  else {
        print(err)
        return
    }
    if let results = result {
        print("Total: \(results.total) results: \(results.perPage) current page: \(results.page)")
        for i in results.data {
            print("ID: \(i.id) STATUS: \(i.status) TIME: \(i.timestamp)")
            print("op params: \(i.operatingParams.rootThreshold), \(i.operatingParams.rotorSpeed), \(i.operatingParams.slack)")
        }

    }
}
