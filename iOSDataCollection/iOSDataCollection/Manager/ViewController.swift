//import UIKit
//
//class ViewController: UIViewController {
//    
//    let calendar = Calendar.current
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.backgroundColor = UIColor.white
//        
//        loadAppOperationDate()
//        loadAppOperationBool()
//        timer()
//    }
//    
//    func timer()
//    {
//        if let appDate = UserDefaults.standard.string(forKey: "AppOperationDate")?.toDate {
//            if self.calendar.isDateInYesterday(appDate) {
//                print(" is Yesterday!!! ")
//            } else {
//                print(" is Not Yesterday!!! ")
//            }
//        }
//    }
//    
//    if !UserDefaults.standard.bool(forKey: "AppOperationBool") {
//        let now = Date()
//        
//        let date = DateFormatter()
//        date.locale = Locale(identifier: "ko_kr")
//        date.timeZone = TimeZone(abbreviation: "KST")
//        date.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        
//        let kr = date.string(from: now)
//        
//        UserDefaults.standard.set(kr, forKey: "AppOperationDate")
//        UserDefaults.standard.set(true, forKey: "AppOperationBool")
//    }
//    
//    func loadAppOperationDate() {
//        
//        if let appDate = UserDefaults.standard.string(forKey: "AppOperationDate")?.toDate {
//            print("최초 앱 실행 시간 : \(appDate), \(Int(appDate.timeIntervalSince1970))")
//        }
//    }
//    
//    func loadAppOperationBool() {
//        print("\(UserDefaults.standard.bool(forKey: "AppOperationBool"))")
//    }
//    
//}
