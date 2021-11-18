//
//  AboutViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/18.
//

import UIKit
import WebKit

class AboutViewController: UIViewController {

    let webView = WKWebView()
    var htmlString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = webView
        // Do any additional setup after loading the view.
        if htmlString == "" {
            self.loadHtmlString()
        } else {
            webView.loadHTMLString(self.htmlString, baseURL: nil)
        }
    }

    func loadHtmlString() {
        let url = URL(string: "https://itsc.nju.edu.cn/main.htm")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: {
            data, response, error in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                      print("server error")
                      return
                  }
            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                        let data = data,
                        let string = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                let range1 = string.range(of: "<div class=\"foot-center\">")
                                self.htmlString = String(string.suffix(from: range1!.lowerBound))
                                let range2 = self.htmlString.range(of: "<div class=\"foot-right\" >")
                                self.htmlString = String(self.htmlString.prefix(upTo: range2!.lowerBound))
                                self.htmlString = "<html>\n<head>\n<meta charset=\"utf-8\">\n</head>\n<body>" + self.htmlString + "</body></html>"
                                self.webView.loadHTMLString(self.htmlString, baseURL: nil)
                            }
            }
        })
        task.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
