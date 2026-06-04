import SwiftUI
import WebKit

struct JitsiWebView: UIViewRepresentable {
    let urlString: String
    @Environment(\.dismiss) private var dismiss

    func makeUIView(context: Context) -> WKWebView {
        // Enable camera/mic for WebRTC in WKWebView (iOS 14.3+)
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = UIColor(named: "Background") ?? .black
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: JitsiWebView

        init(_ parent: JitsiWebView) {
            self.parent = parent
        }
        
        // This intercepts the Jitsi "Leave" button, which redirects to jitsi.github.io by default
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url?.absoluteString {
                // When Jitsi Meet ends, it often navigates to a promotional page or simply drops the room.
                // If it navigates anywhere else after loading the main URL, we assume they left the call.
                if !url.contains(parent.urlString) && url != "about:blank" {
                    parent.dismiss()
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
    }
}
