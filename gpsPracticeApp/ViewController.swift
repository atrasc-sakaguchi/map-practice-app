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
    var annotations:[MKPointAnnotation] = []
    //realmに保存している配列の情報保持
    var pins: [Pin] = []
    

    @IBOutlet weak var map: MKMapView!
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
                self.pins = self.getAllPins()
                //tableviewをリロード
                self.tableView.reloadData()
            }
        })
        //作成した地点入力ダイアログを表示
        self.present(popup, animated: true, completion: nil)
        }
    }
    
    
    /* mapViewに関するメソッド*/
     
    //アノテーションビューを返す（ピンの見た目を設定）
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //アノテーションビューを作成する（ピンのデザイン）
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        //吹き出しを表示可能にする。
        pinView.canShowCallout = true
        
        //右ボタンをアノテーションビューに追加する。
        let button = UIButton()
        button.frame = CGRect(x: 0,y: 0,width: 40,height: 40)
        button.setTitle("削除", for: .normal)
        button.backgroundColor = UIColor.red
        button.setTitleColor(UIColor.white, for: .normal)
        pinView.rightCalloutAccessoryView = button
        
        return pinView
    }
    
    //吹き出しアクササリー押下時の呼び出しメソッド（）吹き出しの削除ボタン
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if(control == view.rightCalloutAccessoryView) {
            //選択されたピンがデータ上で何行目のものか取得し、データを削除する
			if let annotation = view.annotation as? MKPointAnnotation,
			   let index = self.annotations.firstIndex(of: annotation) {	//何番目のピンか
				//realmから対象行を削除
				try! ViewController.realm.write {
					ViewController.realm.delete(self.pins[index])
				}
				
				//表リロード
				self.tableView.reloadData();
				//最後にピンを消す。
				map.removeAnnotation(view.annotation!);
			}
        }
    }
    
    //取得できたピンをマップに追加（マップのロード終了時に呼び出される）
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        //初期化
        annotations.removeAll()
        //Pinを取得
        self.annotations = getAnnotations()
        //map上に追加
        self.annotations.forEach { pin in
            map.addAnnotation(pin)
        }
    }
    
    
    /* ピンの情報の保存、取り出しを行うメソッド*/
    
    //座標をAnnotationに変換するメソッド
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
            self.annotations.append(annotation)
        }
        return self.annotations
    }
    
    //保存していた座標を取り出すメソッド
    func getAllPins() -> [Pin] {
        //初期化
        pins.removeAll()
        //保存していたピンを配列に詰めて返す
        for pin in ViewController.realm.objects(Pin.self) {
            pins.append(pin)
        }
        return pins
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
        self.annotations.append(annotation)
    }
    
    //登録位置の保存メソッド
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
    
    
    /*TableViewの作成*/
       
       //Realmに保存されているオブジェクトを取得
       var realmObjects = ViewController.realm.objects(Pin.self)
          
       //表示する件数を返す
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return realmObjects.count + 1
       }
          
       //セルの表示内容を返す
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           //tableviewのセル設定
           switch indexPath.row{
               //戻るセル
               case realmObjects.count:
                   let secondCell = tableView.dequeueReusableCell(withIdentifier: "SecondCell", for: indexPath)
                   //セルの内容を指定
                   secondCell.textLabel?.text = "日本全体表示"
               return secondCell
               
               //地点表示用のセル設定
               default:
                   let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                   //表示する内容を取得し、セルに設定
                   let title = realmObjects[indexPath.row]
                   cell.textLabel?.text = title.textName
                return cell
            }
       }

       //セルが選択された時の処理
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           //戻るセル
           if indexPath.row == realmObjects.count{
               //選択されたセルから地点の緯度と経度を取得して設定
               let center = CLLocationCoordinate2D(latitude: 38.258595, longitude: 137.6850225)
               //表示範囲設定
               let span = MKCoordinateSpan(latitudeDelta:19.0,longitudeDelta: 19.0)
               //緯度経度と表示範囲
               let region = MKCoordinateRegion(center: center,span: span)
               //緯度経度と表示範囲をマップに設定
               map.setRegion(region, animated:true)
           }
           //地点セル
           else{
               //選択されたセルから地点の緯度と経度を取得して設定
               let annotation = self.annotations[indexPath.row]
               //表示範囲設定
               let span = MKCoordinateSpan(latitudeDelta:2.0,longitudeDelta: 2.0)
               //緯度経度と表示範囲
               let region = MKCoordinateRegion(center: annotation.coordinate,span: span)
               //緯度経度と表示範囲をマップに設定
               map.setRegion(region, animated:true)
               //吹き出しを表示する
               map.selectedAnnotations = [annotation]
           }
       }
       
       //編集処理
       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           //削除
			if editingStyle == .delete{
				
				let pin = self.pins[indexPath.row];
				let annotation = self.annotations[indexPath.row];
				
				//realmに保存している配列の情報（results）から対象行を削除
				self.pins.remove(at: indexPath.row)
				
				//マップ上のピンを削除
				map.removeAnnotation(annotation)
				//annotationの配列(annotations)からも削除
				self.annotations.remove(at: indexPath.row)
				
				//realmから対象行を削除
				try! ViewController.realm.write {
					ViewController.realm.delete(pin)
				}
				realmObjects = ViewController.realm.objects(Pin.self)
				//tableviewから削除(見た目)
				tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            }
       }
       
       //セルの編集制御
       func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
           //新規登録セル(最終行のセル)だった場合、削除不可
           if indexPath.row == realmObjects.count { return false }
           //それ以外は削除可能
           else { return true }
       }
       
    override func viewDidLoad() {
          super.viewDidLoad()
        //デリゲート先に自分を設定
        map.delegate = self
    }
}

