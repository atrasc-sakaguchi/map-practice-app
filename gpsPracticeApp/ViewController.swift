//
//  ViewController.swift
//  gpsPracticeApp
//
//  Created by 坂口美月 on 2020/11/11.
//  Copyright © 2020 坂口美月. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    var point: MKPointAnnotation = MKPointAnnotation()
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //中心座標設定(高田馬場事業所のの緯度経度)
        let center = CLLocationCoordinate2DMake(35.711501, 139.709180)
        //表示範囲設定
        let span = MKCoordinateSpan(latitudeDelta:0.005,longitudeDelta: 0.005)
        //中心座標と表示範囲をマップに登録
        let region = MKCoordinateRegion(center: center,span: span)
        map.setRegion(region, animated:true)

        //ピンを置く場所
        point.coordinate = center
        //吹き出しに表示するタイトル
        point.title = "ATRASC高田馬場事業所"
        self.map.addAnnotation(point)
  
        //デリゲート先に自分を設定
        map.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //アノテーションビューを返す
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //アノテーションビューを作成する。
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        //吹き出しを表示可能にする。
        pinView.canShowCallout = true
        return pinView
    }

    //ピンをタップした時に発生
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    }
}

