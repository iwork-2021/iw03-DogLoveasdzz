//
//  MyTableViewController.swift
//  ITSC
//
//  Created by nju on 2021/11/16.
//

import UIKit

class MyTableViewController: UITableViewController {
    
    var news:[News] = []
    var newsURL:String = ""
    var isNewsLoaded: Bool = false
    var toBeParsedString:[String] = []
    var pageNum: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return news.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyTableViewCell

        // Configure the cell...

        let preNews = self.news[indexPath.row]
        cell.title.text! = preNews.title
        cell.time.text! = preNews.timeStamp
        return cell
    }
    
    func loadToBeParsedString(u: String, index: Int) {
        let url = URL(string: u)!
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
                                self.toBeParsedString[index] = string
                                if index == 0 {
                                    self.pageNum = self.getPageNumber()
                                    for i in 1..<self.pageNum {
                                        self.toBeParsedString.append("")
                                        self.loadToBeParsedString(u: self.newsURL + String(i + 1) + ".htm", index: i)
                                    }
                                }
                                var flag = true
                                for str in self.toBeParsedString {
                                    if str == "" {
                                        flag = false
                                    }
                                }
                                if flag == true {
                                    for pages in 0..<self.toBeParsedString.count {
                                        let arr = self.getNewsItem(index: pages)
                                        for str in arr {
                                            self.parseNewsItem(str: str)
                                        }
                                    }
                                    self.tableView.reloadData()
                                }
                            }
            }
        })
        task.resume()
    }
    
    func getPageNumber() -> Int{
        var str = self.toBeParsedString[0]
        let range = str.range(of: "<em class=\"all_pages\">")!
        str = String(str.suffix(from: range.upperBound))
        var ret = ""
        for ch in str {
            if ch == "<"{
                break
            } else {
                ret = ret + String(ch)
            }
        }
        return Int(ret)!
    }
    
    func getNewsItem(index: Int) -> [String] {
        var ret: [String] = []
        for i in 1...14 {
            var sub = "<li class=\"news n" + String(i) + " clearfix\">"
            var temp = self.toBeParsedString[index]
            let range = temp.range(of: sub)
            if range == nil {
                break
            }
            temp = String(temp.suffix(from: temp.range(of: sub)!.upperBound))
            sub = "</li>"
            temp = String(temp.prefix(upTo: temp.range(of: sub)!.lowerBound))
            ret.append(temp)
        }
        return ret
    }
    
    func parseNewsItem(str: String) {
        let range1 = str.range(of: "<span class=\"news_title\"><a href='")
        let range2 = str.range(of: "' target='_blank' title='")
        if range1 == nil || range2 == nil {
            return
        }
        let url = str[range1!.upperBound..<range2!.lowerBound]
        var temp = String(str.suffix(from: range2!.upperBound))
        let range3 = temp.range(of: ">")
        let range4 = temp.range(of: "</a></span>")
        var title = temp[range3!.upperBound..<range4!.lowerBound]
        if title.count > 16 {
            title = String(title.prefix(16)) + "..."
        }
        temp = String(temp.suffix(from: range4!.upperBound))
        let range5 = temp.range(of: "<span class=\"news_meta\">")
        let range6 = temp.range(of: "</span>")
        let time = temp[range5!.upperBound..<range6!.lowerBound]
        let new = News(title: String(title), timeStamp: String(time), link: self.newsURL + String(url))
        self.news.append(new)
        
    }
    
    func loadAll() {
        self.toBeParsedString.append("")
        self.loadToBeParsedString(u: self.newsURL + ".htm", index: 0)
        self.isNewsLoaded = true
    }
    func setURL(str: String) {
        self.newsURL = str
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNewsDetail" {
            let detail = segue.destination as! DetailViewController
            let cell = sender as! MyTableViewCell
            let indexPath = self.tableView.indexPath(for: cell)
            detail.urls = self.news[indexPath!.row].link
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
