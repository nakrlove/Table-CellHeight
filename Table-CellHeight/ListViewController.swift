//
//  ListViewController.swift
//  Table-CellHeight
//
//  Created by nakrlove on 2022/11/11.
//

import UIKit

class ListViewController: UITableViewController {
  
    @IBOutlet var moreBtn: UIButton!
    
//    override func viewWillAppear(_ animated: Bool) {
//        self.tableView.estimatedRowHeight = 50
//        self.tableView.rowHeight = UITableView.automaticDimension
//    }
//
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let row = self.list[indexPath.row]
//
//        let height = CGFloat(60 + (row.count / 30) * 20)
//        return height
//    }
    
    
    
    
    // 테이블 뷰를 구성할 리스트 데이터
    lazy var list : [MovieVO] = {
        var datalist = [MovieVO]()
        return datalist
    }()
    var page = 1
    // 영화 차트 API를 호출해주는 메소드
    func callMovieAPI() {
        
        // ① 호핀 API 호출을 위한 URI를 생성
        let url = "http://swiftapi.rubypaper.co.kr:2029/hoppin/movies?version=1&page=\(self.page)&count=30&genreId=&order=releasedateasc"
        let apiURI : URL! = URL(string: url)
        
        // ② REST API를 호출
        let apidata = try! Data(contentsOf: apiURI)
        
        // ③ 데이터 전송 결과를 로그로 출력 (반드시 필요한 코드는 아님)
        let log = NSString(data: apidata, encoding: String.Encoding.utf8.rawValue) ?? "데이터가 없습니다"
        NSLog("API Result=\( log )")
        // ④ JSON 객체를 파싱하여 NSDictionary 객체로 변환
        do {
            let apiDictionary = try JSONSerialization.jsonObject(with: apidata, options: []) as! NSDictionary

            // ⑤ 데이터 구조에 따라 차례대로 캐스팅하며 읽어온다.
            let hoppin = apiDictionary["hoppin"] as! NSDictionary
            let movies = hoppin["movies"] as! NSDictionary
            let movie = movies["movie"] as! NSArray

            // ⑥ Iterator 처리를 하면서 API 데이터를 MovieVO 객체에 저장한다.
            for row in movie {

                // 순회 상수를 NSDictionary 타입으로 캐스팅
                let r = row as! NSDictionary

                // 테이블 뷰 리스트를 구성할 데이터 형식
                let mvo = MovieVO( )

                // movie 배열의 각 데이터를 mvo 상수의 속성에 대입
                mvo.title       = r["title"] as? String
                mvo.description = r["genreNames"] as? String
                mvo.thumbnail   = r["thumbnailImage"] as? String
                mvo.detail      = r["linkUrl"] as? String
                mvo.rating      = ((r["ratingAverage"] as! NSString).doubleValue)

                // 웹상에 있는 이미지를 읽어와 UIImage 객체로 생성
                let url: URL! = URL(string: mvo.thumbnail!)
                let imageData = try! Data(contentsOf: url)
                mvo.thumbnailImage = UIImage(data:imageData)

                // list 배열에 추가
                self.list.append(mvo)
            }

            // ⑦ 전체 데이터 카운트를 얻는다.
            let totalCount = (hoppin["totalCount"] as? NSString)!.integerValue

            // ⑧ totalCount가 읽어온 데이터 크기와 같거나 클 경우 더보기 버튼을 막는다.
            if (self.list.count >= totalCount) {
                self.moreBtn.isHidden = true
            }

        } catch {
            NSLog("Parse Error!!")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callMovieAPI()
        // Do any additional setup after loading the view.
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.list[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MovieCell
        cell.title?.text = row.title
        cell.desc?.text = row.description
        cell.opendate?.text = row.opendate
        cell.rating?.text = "\(row.rating!)"
//        cell.thumbnail?.image = UIImage(named: row.thumbnail!)
        DispatchQueue.main.async(execute: {
            NSLog("비동기 방식으로 실행되는 부분입니다")
            cell.thumbnail.image = self.getThumbnailImage(indexPath.row)
        })
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("선택된 행은 \(indexPath.row) 번째 행입니다.")
//        let msg = "선택된 행은 \(indexPath.row) 번째 행입니다."
//        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
//        let ok = UIAlertAction(title: "확인", style: .cancel) { (_) in
//            
//        }
//        alert.addAction(ok)
//        
//        self.present(alert,animated: false)
    }
    
    
    // 섬네일 이미지를 제공하는 메소드
    func getThumbnailImage(_ index : Int) -> UIImage {
        // 인자값으로 받은 인덱스를 기반으로 해당하는 배열 데이터를 읽어옴
        let mvo = self.list[index]
        
        // 메모이제이션 처리 : 저장된 이미지가 있을 경우 이를 반환하고, 없을 경우 내려받아 저장한 후 반환함
        if let savedImage = mvo.thumbnailImage {
            return savedImage
        } else {
            let url: URL! = URL(string: mvo.thumbnail!)
            let imageData = try! Data(contentsOf: url)
            mvo.thumbnailImage = UIImage(data:imageData) // UIImage 객체를 생성하여 MovieVO 객체에 우선 저장함
            
            return mvo.thumbnailImage! // 저장된 이미지를 반환
        }
    }
    
    @IBAction func more(_ sender: Any) {
        self.page += 1
        self.callMovieAPI()
        self.tableView.reloadData()
    }
}

extension ListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_detail" {
            let path = self.tableView.indexPath(for: sender as! MovieCell)
            
            let detailVC = segue.destination as? DetailViewController
            detailVC?.mvo = self.list[path!.row]
        }
    }
}
