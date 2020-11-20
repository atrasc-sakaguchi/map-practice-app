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

class ViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource
{
    //Realmの取得
    static let realm = try! Realm()
    //ピンのannotation情報を保持
    var pins:[MKPointAnnotation] = []
    //realmに保存している配列の情報ぞ保持
    var results: [Pin] = []
    
    //マップビューの接続
    @IBOutlet weak var map: MKMapView!
    //テーブルビューの接続
    @IBOutlet weak var tableView: UITableView!
    
    //マップビュー長押し時の呼び出しメソッド
    @IBAction func pressMap(sender: UILongPressGestureRecognizer!) {
        //タップした位置（CGPoint）を指定
        let tapPoint = sender.location(in: map)
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
                    //登録後のreslutsを更新
                    self.results = self.getAllPins()
                    //tableviewをリロード
                    self.tableView.reloadData()
                }
            })
        //作成した地点入力ダイアログを表示
        self.present(popup, animated: true, completion: nil)
        }
    }
    
    
    /*TableViewの作成*/
    
    //Realmに保存されているオブジェクトを取得
    let realmObjects = ViewController.realm.objects(Pin.self)
       
    //表示する件数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realmObjects.count
    }
       
    //セルの表示内容を返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //表示する内容を取得し、セルに設定
        let title = realmObjects[indexPath.row]
        cell.textLabel?.text = title.textName
        return cell
    }

    //セルが選択された時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //選択されたセルから地点の緯度と経度を取得して設定
        let annotation = self.pins[indexPath.row]
        //表示範囲設定
        let span = MKCoordinateSpan(latitudeDelta:2.0,longitudeDelta: 2.0)
        //緯度経度と表示範囲
        let region = MKCoordinateRegion(center: annotation.coordinate,span: span)
        //緯度経度と表示範囲をマップに設定
        map.setRegion(region, animated:true)
        //吹き出しを表示する
        map.selectedAnnotations = [annotation]
    }
    
    //編集処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //削除
        if editingStyle == .delete{
            // Realm内のデータを削除
            do{
                //mapの今の状態を取得
                mapViewDidFinishLoadingMap(map)
                map.removeAnnotation(pins[indexPath.row])
                //tableviewリロード
                tableView.reloadData()
                //realmから対象行を削除
                try ViewController.realm.write {
                    ViewController.realm.delete(self.results[indexPath.row])
                }
                //annotationの配列からも削除
                self.pins.remove(at: indexPath.row)
                //tableviewからも削除
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            
                //mapの今の状態を取得
                mapViewDidFinishLoadingMap(map)

            }
            catch{
            }
        }
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
        //初期化
        pins.removeAll()
        //Pinを取得してMap上に表示する
        self.pins = getAnnotations()
        self.pins.forEach { pin in
        map.addAnnotation(pin)
        }
    }
    
    
    /* ピンの情報の保存、取り出しを行うメソッド*/
    
    //座標をAnnotationに変換
    func getAnnotations() -> [MKPointAnnotation]  {
        //保存していたピンの座標を取得
        let pins = getAllPins()
        
        //緯度・経度をCLLocationCoordinate2Dに変換してアノテーションに設定
        pins.forEach { pin in
            let annotation = MKPointAnnotation()
            let centerCoordinate = CLLocationCoordinate2D(latitude: (pin.latitude as NSString).doubleValue, longitude:(pin.longitude as NSString).doubleValue)
            //緯度・経度を取得
            annotation.coordinate = centerCoordinate
            //地点名を取得
            annotation.title = pin.textName
            //取得した情報をannotationに追加
            self.pins.append(annotation)
        }
        return self.pins
    }
    
    //保存していた座標を取り出す
    func getAllPins() -> [Pin] {
        //初期化
        results.removeAll()
        //保存していたピンを配列に詰めて返す
        for pin in ViewController.realm.objects(Pin.self) {
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
        //pinsに追加
        self.pins.append(annotation)
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
        try! ViewController.realm.write {
            ViewController.realm.add(pin)
        }
    }
    
    override func viewDidLoad() {
          super.viewDidLoad()
        //デリゲート先に自分を設定
        map.delegate = self
    }
}

