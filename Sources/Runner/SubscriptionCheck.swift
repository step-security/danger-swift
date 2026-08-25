import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logger

func validateSubscription(logger: Logger) {
    let upstream = "danger/swift"
    let action = ProcessInfo.processInfo.environment["GITHUB_ACTION_REPOSITORY"] ?? ""
    let docsUrl = "https://docs.stepsecurity.io/actions/stepsecurity-maintained-actions"

    var repoPrivate: Bool?
    if let eventPath = ProcessInfo.processInfo.environment["GITHUB_EVENT_PATH"],
       let data = try? Data(contentsOf: URL(fileURLWithPath: eventPath)),
       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let repository = json["repository"] as? [String: Any] {
        repoPrivate = repository["private"] as? Bool
    }

    logger.logInfo("\u{001B}[1;36mStepSecurity Maintained Action\u{001B}[0m")
    logger.logInfo("Secure drop-in replacement for \(upstream)")
    if repoPrivate == false { logger.logInfo("\u{001B}[32m\u{2713} Free for public repositories\u{001B}[0m") }
    logger.logInfo("\u{001B}[36mLearn more:\u{001B}[0m \(docsUrl)")
    logger.logInfo("")

    if repoPrivate == false { return }

    let serverUrl = ProcessInfo.processInfo.environment["GITHUB_SERVER_URL"] ?? "https://github.com"
    var body: [String: String] = ["action": action]
    if serverUrl != "https://github.com" { body["ghes_server"] = serverUrl }

    guard let repo = ProcessInfo.processInfo.environment["GITHUB_REPOSITORY"],
          let url = URL(string: "https://agent.api.stepsecurity.io/v1/github/\(repo)/actions/maintained-actions-subscription"),
          let bodyData = try? JSONSerialization.data(withJSONObject: body)
    else { return }

    var request = URLRequest(url: url, timeoutInterval: 3)
    request.httpMethod = "POST"
    request.httpBody = bodyData
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let semaphore = DispatchSemaphore(value: 0)
    URLSession.shared.dataTask(with: request) { _, response, error in
        defer { semaphore.signal() }
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 403 {
            logger.logError("\u{001B}[1;31mThis action requires a StepSecurity subscription for private repositories.\u{001B}[0m")
            logger.logError("\u{001B}[31mLearn how to enable a subscription: \(docsUrl)\u{001B}[0m")
            exit(1)
        }
        if error != nil {
            logger.logInfo("Timeout or API not reachable. Continuing to next step.")
        }
    }.resume()
    semaphore.wait()
}
