//
//  DetailViewController.swift
//  Table-CellHeight
//
//  Created by nakrlove on 2022/11/12.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    @IBOutlet var wv: WKWebView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    var mvo: MovieVO!
    
    override func viewDidLoad() {
        NSLog("linkurl = \(self.mvo.detail!) , title = \(self.mvo.title!)")
        
        self.spinner.startAnimating()
        self.wv.navigationDelegate = self
        let navibar = self.navigationItem
        navibar.title = self.mvo.title
        print("URL = \((self.mvo.detail)!)/web")
        let url = URL(string: (self.mvo.detail)!)
//        let url = URL(string: "http://www.naver.com")
        let req = URLRequest(url: url!)
        self.wv.load(req)
    }
    
    
}


extension UIViewController {
    func alert(_ message: String, onClick: (() -> Void)? = nil ){
        let controller = UIAlertController(title: nil, message: message, preferredStyle:.alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel) { (_) in
            onClick?()
        })
        
        DispatchQueue.main.async {
            self.present(controller, animated: false)
        }
    }
}


extension DetailViewController: WKNavigationDelegate {
    
   
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        print(" 1) startAnimating #########")
//        self.spinner.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(" 2) stopAnimating didFinish #########")
        self.spinner.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.spinner.stopAnimating()
        print(" 3) stopAnimating didFail #########")
        self.alert("상세 페이지를 읽어오지 못했습니다"){
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.spinner.stopAnimating()
        print(" 4) stopAnimating didFailProvisionalNavigation #########")
        self.alert("상세 페이지를 읽어오지 못했습니다"){
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(" 5 ) startAnimating #########")
        print("absoluteString = \(String(describing: navigationAction.request.url?.absoluteString)), absoluteURL = \(String(describing: navigationAction.request.url?.absoluteURL))")
        decisionHandler(.allow)
    }
    
}

