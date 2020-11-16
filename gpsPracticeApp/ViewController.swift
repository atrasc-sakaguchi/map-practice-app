//
//  ViewController.swift
//  gpsPracticeApp
//
//  Created by 坂口美月 on 2020/11/11.
//  Copyright © 2020 坂口美月. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class Pin: Object {
   // 緯度
   @objc dynamic var latitude = ""
   // 経度
   @objc dynamic var longitude = ""
    
//    @objc dynamic var textName = ""
}

class ViewController: UIViewController, MKMapViewDelegate {

    var point: MKPointAnnotation = MKPointAnnotation()
    
    let annotation = MKPointAnnotation()
    var annotationArray: [MKAnnotation] = []
       var textName = ""
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

        //デリゲート先に自分を設定
        map.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // マップのロードが終わった時に呼ばれる
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        //Pinを取得してMap上に表示する
        let annotations = getAnnotations()
           annotations.forEach { annotation in
               mapView.addAnnotation(annotation)
           }
        }

    //アノテーションビューを返す
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //アノテーションビューを作成する。
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        //吹き出しを表示可能にする。
        pinView.canShowCallout = true
        return pinView
    }

    //マップビュー長押し時の呼び出しメソッド
    @IBAction func pressMap(sender: UILongPressGestureRecognizer) {
        //ロングタップ開始
        if sender.state == .began {
        
        }
        //ロングタップ終了（手を離した）
        else if sender.state == .ended {
            //タップした位置（CGPoint）を指定
            let tapPoint = sender.location(in: view)
            //取得した位置を緯度経度に変換
            let center = map.convert(tapPoint, toCoordinateFrom: map)
            //緯度
            let lat:String = center.latitude.description
            //経度
            let lon:String = center.longitude.description
        
            //ロングタップを検出した位置にピンを立てる
            point.coordinate = center
            map.addAnnotation(point)
            annotation.coordinate = CLLocationCoordinate2DMake(center.latitude,center.longitude)
            //ポップアップを表示して、登録位置の名前を取得する
            var alertTextField: UITextField?
            let popup = UIAlertController(
                title: "位置登録",
                message: "登録する名前を入力してください。",
                preferredStyle: UIAlertController.Style.alert)
            popup.addTextField(
            configurationHandler: {(textField: UITextField!) in
                alertTextField = textField
            })
            
        //キャンセルボタン
        popup.addAction(
            UIAlertAction(
                title: "キャンセル",
                style: UIAlertAction.Style.cancel,
                handler: nil))
        //登録ボタン
        popup.addAction(
            UIAlertAction(
                title: "登録",
                style: UIAlertAction.Style.default) { _ in
                if let text = alertTextField?.text {
                self.annotation.title = text
                self.textName = text
                }
            }
        )
            
        //位置登録ダイアログを表示
         self.present(popup, animated: true, completion: nil)
        annotationArray.append(annotation)
        self.map.addAnnotations(annotationArray)
            
        //保存処理
        savePin(latitude: lat, longitude: lon)
        annotation.title = textName       }
   }

    //ピンをタップした時に発生
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    }
    
    //登録位置の保存処理
    func savePin(latitude: String, longitude: String) {
        let pin = Pin()
        pin.latitude = latitude
        pin.longitude = longitude
        
        //Realmインスタンスを生成
        let realm = try! Realm()
        try! realm.write {
            realm.add(pin)
        }
    }

    //保存していた座標の取得
    func getAllPins() -> [Pin] {
       let realm = try! Realm()
       var results: [Pin] = []
       for pin in realm.objects(Pin.self) {
           results.append(pin)
       }
       return results
    }
    
    //座標をAnnotationに変換
    func getAnnotations() -> [MKPointAnnotation]  {
       let pins = getAllPins()
       var results:[MKPointAnnotation] = []
       
       pins.forEach { pin in
           let annotation = MKPointAnnotation()
           let centerCoordinate = CLLocationCoordinate2D(latitude: (pin.latitude as NSString).doubleValue, longitude:(pin.longitude as NSString).doubleValue)
           annotation.coordinate = centerCoordinate
           results.append(annotation)
       }
       return results
    }
    
    
    
    
}

