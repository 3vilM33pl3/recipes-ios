import Foundation

actor NetworkManager {
    static let shared = NetworkManager()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Configuration.requestTimeout
        config.timeoutIntervalForResource = Configuration.uploadTimeout
        config.waitsForConnectivity = true

        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Generic Request

    func request<T: Decodable>(
        endpoint: APIEndpoint,
        method: HTTPMethod = .get
    ) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: method)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 404 {
                throw APIError.notFound
            } else if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            } else {
                let errorMessage = String(data: data, encoding: .utf8)
                throw APIError.serverError(httpResponse.statusCode, errorMessage)
            }
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Multipart Upload

    func uploadMultipart(
        imageData: Data,
        fileName: String,
        mimeType: String = "image/jpeg"
    ) async throws -> RecipeUploadResponse {
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: Configuration.baseURL.appendingPathComponent("api/recipes"))
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let body = createMultipartBody(
            imageData: imageData,
            fileName: fileName,
            mimeType: mimeType,
            boundary: boundary
        )

        let (data, response) = try await session.upload(for: request, from: body)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8)
            throw APIError.uploadFailed(errorMessage ?? "Unknown error")
        }

        do {
            return try decoder.decode(RecipeUploadResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Delete Request

    func delete(endpoint: APIEndpoint) async throws -> RecipeDeleteResponse {
        let request = try buildRequest(endpoint: endpoint, method: .delete)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8)
            throw APIError.serverError(httpResponse.statusCode, errorMessage)
        }

        do {
            return try decoder.decode(RecipeDeleteResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Helper Methods

    private func buildRequest(
        endpoint: APIEndpoint,
        method: HTTPMethod
    ) throws -> URLRequest {
        var components = URLComponents(url: Configuration.baseURL, resolvingAgainstBaseURL: true)
        components?.path = endpoint.path
        components?.queryItems = endpoint.queryItems

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        return request
    }

    private func createMultipartBody(
        imageData: Data,
        fileName: String,
        mimeType: String,
        boundary: String
    ) -> Data {
        var body = Data()

        // Add image field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        // Closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }
}

// MARK: - API Endpoint

enum APIEndpoint {
    case recipes(page: Int, limit: Int)
    case recipeDetail(slug: String)
    case uploadRecipe
    case deleteRecipe(slug: String)
    case qrCode(slug: String)

    var path: String {
        switch self {
        case .recipes:
            return "/api/recipes"
        case .recipeDetail(let slug):
            return "/api/recipes/\(slug)"
        case .uploadRecipe:
            return "/api/recipes"
        case .deleteRecipe(let slug):
            return "/api/recipes/\(slug)"
        case .qrCode(let slug):
            return "/api/recipes/\(slug)/qr"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .recipes(let page, let limit):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        default:
            return nil
        }
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
