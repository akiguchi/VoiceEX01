//
//  RealmData.swift
//  ATappSuiteProto
//
//  Created by 秋口俊輔 on 2021/01/02.
//

import Foundation
import RealmSwift

class TimeTimerData: Object {
    @objc dynamic var id:Float = 0
    @objc dynamic var width:Float = 0
    @objc dynamic var height:Float = 0
    @objc dynamic var timer:Float = 0
 
    /*
    @objc dynamic var id:Int = 0
    @objc dynamic var width:Int = 0
    @objc dynamic var height:Int = 0
    @objc dynamic var timer:Int = 0
    */
}

class VoiceRecognitionData: Object {
    @objc dynamic var title:String = ""
    @objc dynamic var text:String = ""
}
