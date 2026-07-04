import Foundation
import Combine

class GoogleDriveService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var selectedFolderID: String?
    @Published var selectedFolderName: String?
    @Published var isSyncing = false
    @Published var error: String?
    
    var authToken: String? {
        didSet {
            isAuthenticated = authToken != nil
        }
    }
    
    private let apiBaseURL = "https://www.googleapis.com/drive/v3"
    private var syncTask: Task<Void, Never>?
    
    func uploadNote(_ note: Note, markdown: String, authToken: String) async {
        guard let folderID = selectedFolderID else {
            error = "Zielordner nicht gesetzt"
            return
        }
        
        DispatchQueue.main.async {
            self.isSyncing = true
        }
        
        do {
            let fileID = try await createFile(
                filename: note.filename,
                content: markdown,
                parentFolderID: folderID,
                authToken: authToken
            )
            
            DispatchQueue.main.async {
                self.error = nil
                self.isSyncing = false
            }
            
            return fileID
        } catch {
            DispatchQueue.main.async {
                self.error = "Upload fehler: \(error.localizedDescription)"
                self.isSyncing = false
            }
        }
    }
    
    private func createFile(
        filename: String,
        content: String,
        parentFolderID: String,
        authToken: String
    ) async throws -> String {
        let url = URL(string: "\(apiBaseURL)/files?uploadType=multipart")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/related; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        let metadata: [String: Any] = [
            "name": filename,
            "mimeType": "text/markdown",
            "parents": [parentFolderID]
        ]
        
        let metadataJSON = try JSONSerialization.data(withJSONObject: metadata)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json; charset=UTF-8\r\n\r\n".data(using: .utf8)!)
        body.append(metadataJSON)
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Type: text/markdown\r\n\r\n".data(using: .utf8)!)
        body.append(content.data(using: .utf8)!)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "GoogleDrive", code: -1, userInfo: [NSLocalizedDescriptionKey: "Upload fehlgeschlagen"])
        }
        
        let result = try JSONDecoder().decode(FileResponse.self, from: data)
        return result.id
    }
    
    func fetchFolders(authToken: String) async throws -> [Folder] {
        let url = URL(string: "\(apiBaseURL)/files?q=mimeType='application/vnd.google-apps.folder'&spaces=drive&fields=files(id,name)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "GoogleDrive", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ordner abrufen fehlgeschlagen"])
        }
        
        let result = try JSONDecoder().decode(FolderListResponse.self, from: data)
        return result.files
    }
}

struct FileResponse: Codable {
    let id: String
}

struct FolderListResponse: Codable {
    let files: [Folder]
}

struct Folder: Codable, Identifiable {
    let id: String
    let name: String
}
