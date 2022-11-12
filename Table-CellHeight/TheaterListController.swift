//
//  TeatherListController.swift
//  Table-CellHeight
//
//  Created by nakrlove on 2022/11/12.
//

import UIKit

class TheaterListController: UITableViewController {
    

    @IBOutlet var spinner: UIActivityIndicatorView!
    var list = [NSDictionary]()
   
    var startPint = 0
    let sList = 100
    let type = "json"
    override func viewDidLoad() {
        self.RequestTheater()
    }
    
    func RequestTheater() {
        
       
        
        print(" ########## RequestTheater #########")
        let requestURL = "http://swiftapi.rubypaper.co.kr:2029/theater/list?s_page=\(self.startPint)&s_list=\(sList)&type=\(type)"
        
        let urlObj = URL(string: requestURL)
        
        do {
            let stringdata = try NSString(contentsOf: urlObj!, encoding: 0x80_000_422)
            let encdata = stringdata.data(using: String.Encoding.utf8.rawValue)
        
            let apiArray = try JSONSerialization.jsonObject(with: encdata!, options: []) as? NSArray
            
            for obj in apiArray! {
                self.list.append(obj as! NSDictionary)
            }
           
        }catch {
            alert("데이터를 불러오는데 실패하였습니다!"){
                
            }
        }
        self.spinner.stopAnimating()
        self.startPint += sList
    }
}

extension TheaterListController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = self.list[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tCell") as! TheaterCell
        cell.name?.text = obj["상영관명"] as? String
        cell.tel?.text = obj["연락처"] as? String
        cell.addr?.text = obj["소재지도로명주소"] as? String
        
        return cell
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
      {
          let offsetY = scrollView.contentOffset.y
          let contentHeight = scrollView.contentSize.height
          
          if offsetY > contentHeight - scrollView.frame.height
          {
            
            if self.spinner.isAnimating {
                return
            }
            self.spinner.startAnimating()
            DispatchQueue.main.async {
                print(" ########## scrollViewDidScroll #########")
                self.RequestTheater()
                self.tableView.reloadData()
            }
            
            
//              if !fetchingMore
//              {
////                  beginBatchFetch()
//              }
          }
      }
      
//      func beginBatchFetch()
//      {
//          fetchingMore = true
//          tableView.reloadSections(IndexSet(integer: 2), with: .none)
//          DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
//              let newItems = (self.items.count...self.items.count + 10).map { index in index }
//              self.items.append(contentsOf: newItems)
//              self.fetchingMore = false
//              self.tableView.reloadData()
//          })
//      }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_map" {
            let path = self.tableView.indexPath(for: sender as! UITableViewCell)
            let data = self.list[path!.row]
            
            (segue.destination as? TheaterViewController)?.param = data
        }
    }
}
