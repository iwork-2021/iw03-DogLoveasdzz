//
//  DetailViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/18.
//

import UIKit

class DetailViewController: UIViewController {
    
    var urls: String = ""
    @IBOutlet weak var textTitle: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var mainContext: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mainContext.text! = ""
        self.textTitle.text! = ""
        // Do any additional setup after loading the view.
        self.loadContext()
    }
    
    
    func loadContext() {
        let url = URL(string: self.urls)!
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
                                self.textTitle.text! = self.getTitle(htmlString: string)
                                self.mainContext.text! = self.getContext(htmlString: string)
                            }
            }
        })
        task.resume()
    }

    func getTitle(htmlString: String) -> String {
        let range3 = htmlString.range(of: "<title>")
        let range4 = htmlString.range(of: "</title>")
        let title = htmlString[range3!.upperBound..<range4!.lowerBound]
        return String(title)
    }
    
    func getContext(htmlString: String) -> String {
        if let range1 = htmlString.range(of: "<div class=\"read\">") {
            var temp = String(htmlString.suffix(from: range1.upperBound))
            let range2 = temp.range(of: "</p></div></div>")
            if range2 == nil {
                return ""
            }
            temp = String(temp.prefix(upTo: range2!.lowerBound))
        
            if let imgRange1 = temp.range(of: "img") {
                var imgURL = String(temp.suffix(from: imgRange1.upperBound))
                let imgRange2 = imgURL.range(of: "src=\"")
                imgURL = String(imgURL.suffix(from: imgRange2!.upperBound))
                let imgRange3 = imgURL.range(of: "\"")
                imgURL = String(imgURL.prefix(upTo: imgRange3!.lowerBound))
                imgURL = "https://itsc.nju.edu.cn" + imgURL
                self.image.load(url: URL(string: imgURL)!)
            }
        
            while let range = temp.range(of: "<") {
                let range0 = temp.range(of: ">")
                temp = String(temp.prefix(upTo: range.lowerBound)) + String(temp.suffix(from: range0!.upperBound))
            }
            temp = temp.replacingOccurrences(of: "&quot;", with: "\"")
            temp = temp.replacingOccurrences(of: "&amp;", with: "&")
            temp = temp.replacingOccurrences(of: "&lt;", with: "<")
            temp = temp.replacingOccurrences(of: "&gt;", with: ">")
            temp = temp.replacingOccurrences(of: "&nbsp;", with: " ")
            return temp
        } else {
            return ""
        }
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

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
