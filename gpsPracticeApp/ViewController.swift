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

//保存処理の関数定義
class Pin: Object {
    //緯度
    @objc dynamic var latitude = ""
    //経度
    @objc dynamic var longitude = ""
    //登録地名
    @objc dynamic var textName = ""
}

class ViewController: UIViewController, MKMapViewDelegate {
    
    //Realmの取得
    let realm = try! Realm()
    
    //マップビューの接続
    @IBOutlet weak var map: MKMapView!
    
    //マップビュー長押し時の呼び出しメソッド
    @IBAction func pressMap(sender: UILongPressGestureRecognizer!) {
        //タップした位置（CGPoint）を指定
        let tapPoint = sender.location(in: view)
        //取得した位置を緯度,経度に変換
        let center = self.map.convert(tapPoint, toCoordinateFrom: map)
        //緯度
        let lat:String = center.latitude.description
        //経度
        let lon:String = center.longitude.description
        
        //ロングタップ開始
        if sender.state == .began {
        }
        //ロングタップ終了（手を離したとき）
        else if sender.state == .ended {
            //地点入力ダイアログを作成
            var alertTextField: UITextField?
            let popup = UIAlertController( title: "位置登録",message: "登録する名前を入力してください。",preferredStyle: UIAlertController.Style.alert)
                popup.addTextField(configurationHandler: {(textField: UITextField!) in alertTextField = textField })
            //キャンセルボタン
            popup.addAction( UIAlertAction( title: "キャンセル", style: UIAlertAction.Style.cancel,handler: nil ))
            //登録ボタン
            popup.addAction( UIAlertAction(title: "登録",style: UIAlertAction.Style.default ) { _ in
                //テキストがnilじゃなかった場合（nilの場合地点名の登録なし）
                if let text = alertTextField?.text {
                    //ピンを立てる
                    self.addAnnotation(latitude: center.latitude, longitude: center.longitude, title: text)
                    //登録したピンの情報を保存
                    ViewController().savePin(latitude: lat, longitude: lon, location: text)
                }
            })
        //作成した地点入力ダイアログを表示
        self.present(popup, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
         super.viewDidLoad()
         //デリゲート先に自分を設定
         map.delegate = self
     }
    
    /* mapViewに関するメソッド*/
     
    //アノテーションビューを返す（ピンの見た目を設定）
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //アノテーションビューを作成する（ピンのデザイン）
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        //吹き出しを表示可能にする。
        pinView.canShowCallout = true
        
        return pinView
    }
    
    //取得できたピンをマップに追加（マップのロード終了時に呼び出される）
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        //Pinを取得してMap上に表示する
        let annotations = getAnnotations()
        annotations.forEach { annotation in
            mapView.addAnnotation(annotation)
        }
    }
    
    /* ピンの情報の保存、取り出しを行うメソッド*/
    
    //座標をAnnotationに変換
    func getAnnotations() -> [MKPointAnnotation]  {
        //保存していたピンの座標を取得
        let pins = getAllPins()
        
        var results:[MKPointAnnotation] = []
        //緯度・経度をCLLocationCoordinate2Dに変換してアノテーションに設定
        pins.forEach { pin in
            let annotation = MKPointAnnotation()
            let centerCoordinate = CLLocationCoordinate2D(latitude: (pin.latitude as NSString).doubleValue, longitude:(pin.longitude as NSString).doubleValue)
            //緯度・経度を取得
            annotation.coordinate = centerCoordinate
            //地点名を取得
            annotation.title = pin.textName
            //取得した情報を追加
            results.append(annotation)
       }
       return results
    }
    
    //保存していた座標を取り出す
    func getAllPins() -> [Pin] {
        //保存していたピンを配列に詰めて返す
        var results: [Pin] = []
        for pin in realm.objects(Pin.self) {
            results.append(pin)
        }
        return results
    }
    
    //ピンの生成、マップへの追加メソッド
    func addAnnotation( latitude: CLLocationDegrees, longitude: CLLocationDegrees, title:String) {
        //ピンの生成
        let annotation = MKPointAnnotation()
        //緯度経度を指定
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        //地点名を設定
        annotation.title = title
        //mapに追加
        map.addAnnotation(annotation)
    }
    
    //登録位置の保存処理
    func savePin(latitude: String, longitude: String ,location: String) {
        let pin = Pin()
        //緯度
        pin.latitude = latitude
        //経度
        pin.longitude = longitude
        //登録地点名
        pin.textName = location
        
        //Realmへのデータ追加
        try! realm.write {
            realm.add(pin)
        }
    }
}

