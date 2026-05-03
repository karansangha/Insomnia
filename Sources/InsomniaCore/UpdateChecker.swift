import Foundation
import Combine

public class UpdateChecker: ObservableObject {
    @Published public var updateAvailable: Bool = false
    @Published public var latestVersion: String = ""
    @Published public var releaseURL: URL? = nil

    private var currentVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    private let repoOwner = "karansangha"
    private let repoName = "Insomnia"

    public init() {}

    public static func isNewer(_ remote: String, than local: String) -> Bool {
        remote.compare(local, options: .numeric) == .orderedDescending
    }

    public func checkForUpdates() {
        guard let url = URL(string: "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest") else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let tagName = json["tag_name"] as? String {

                    let cleanTag = tagName.replacingOccurrences(of: "v", with: "")

                    DispatchQueue.main.async {
                        if UpdateChecker.isNewer(cleanTag, than: self?.currentVersion ?? "") {
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
