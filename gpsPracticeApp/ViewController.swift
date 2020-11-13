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

    var location:[String] = []
    
    var annotationArray: [MKAnnotation] = []
        static var hairetu:[User] = []
    
    
    var textName = ""
    var a = 0.0
    var b = 0.0
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let a = UserDefaults.standard.array(forKey: "annotation") as? [[Any]] else{
            //デリゲート先に自分を設定
            map.delegate = self
            
            return
        }
        //取り出した情報を変換
        a.forEach { userText in
            let user = User(latitude: userText[0], longitude: userText[1], Name: userText[2])
            //tableViewへ格納
            ViewController.hairetu.append(user)
        }
        print ()
//        let c = UserDefaults.standard.object(forKey: "location")
        
//        point.coordinate = CLLocationCoordinate2DMake c[0]
        
//        //中心座標設定(高田馬場事業所のの緯度経度)
//        let center = CLLocationCoordinate2DMake(35.711501, 139.709180)
//        //表示範囲設定
//          let span = MKCoordinateSpan(latitudeDelta:0.005,longitudeDelta: 0.005)
////        //中心座標と表示範囲をマップに登録
//          let region = MKCoordinateRegion(center: center,span: span)
//          map.setRegion(region, animated:true)
//
//        //ピンを置く場所
//        point.coordinate = center
//        //吹き出しに表示するタイトル
//        point.title = "ATRASC高田馬場事業所"
//        self.map.addAnnotation(point)
  
        
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

    //マップビュー長押し時の呼び出しメソッド
    @IBAction func pressMap(sender: UILongPressGestureRecognizer) {
        // ロングタップ開始
       if sender.state == .began {
       }
       // ロングタップ終了（手を離した）
       else if sender.state == .ended {
        // タップした位置（CGPoint）を指定
         let tapPoint = sender.location(in: view)
         //取得した位置を緯度経度に変換
         let center = map.convert(tapPoint, toCoordinateFrom: map)


        a = center.longitude
        b = center.latitude
        
        print(a)
      
        

         
         // ロングタップを検出した位置にピンを立てる
         point.coordinate = center
         map.addAnnotation(point)
        
        let annotation = MKPointAnnotation()
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
                    annotation.title = text
                    self.location.append(text)
                 
                    print(self.a)
                    self.textName = text
                    ViewController.hairetu += [User(latitude: self.a,longitude: self.b,Name: self.textName)]
                    ViewController().savePoint()
                }
            }
        )
        //位置登録ダイアログを表示
         self.present(popup, animated: true, completion: nil)
        

        annotation.title = textName
               annotationArray.append(annotation)
        
   
               location.append(textName)

               self.map.addAnnotations(annotationArray)
       }
   }

    //ピンをタップした時に発生
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    }
    
    //登録位置の保存処理
    func savePoint (){
        print(a,b,textName)
//        hairetu += [User(latitude: a,longitude: b,Name: textName)]
    //配列へ変換
    var users2:[[Any]] = [];
        ViewController.hairetu.forEach { hairetu in
       users2.append(hairetu.toArray());
    }

        UserDefaults.standard.set(users2, forKey: "annotation")
//        UserDefaults.standard.set(location , forKey: "location")
        }

}

