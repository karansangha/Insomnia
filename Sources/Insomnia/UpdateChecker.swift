import Foundation
import SwiftUI

class UpdateChecker: ObservableObject {
    @Published var updateAvailable: Bool = false
    @Published var latestVersion: String = ""
    @Published var releaseURL: URL? = nil
    
    private var currentVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    private let repoOwner = "karansangha"
    private let repoName = "Insomnia"
    
    func checkForUpdates() {
        guard let url = URL(string: "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let tagName = json["tag_name"] as? String {
                    
                    let cleanTag = tagName.replacingOccurrences(of: "v", with: "")
                    
                    DispatchQueue.main.async {
                        if cleanTag.compare(self?.currentVersion ?? "", options: .numeric) == .orderedDescending {
                            self?.latestVersion = tagName
                            self?.updateAvailable = true
                            if let htmlUrl = json["html_url"] as? String {
                                self?.releaseURL = URL(string: htmlUrl)
                            }
                        }
                    }
                }
            } catch {
                print("Failed to check for updates: \(error)")
            }
        }.resume()
    }
}
