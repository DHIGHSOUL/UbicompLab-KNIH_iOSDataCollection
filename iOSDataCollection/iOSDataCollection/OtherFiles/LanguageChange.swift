//
//  LanguageChange.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/08/24.
//

import Foundation

struct LanguageChange {
    
    // Words in Tab Bar Controller
    struct TabBarWord {
        static let measure = "measure".localized
        static let appSensor = "appSensor".localized
        static let appMenu = "appMenu".localized
    }
    
    // Words in Main View
    struct MainViewWord {
        static let accX = "accX".localized
        static let accY = "accY".localized
        static let accZ = "accZ".localized
        static let gyrX = "gyrX".localized
        static let gyrY = "gyrY".localized
        static let gyrZ = "gyrZ".localized
        static let altitude = "altitude".localized
        static let pressure = "pressure".localized
        static let sensorLeftTime = "sensorLeftTime".localized
    }
    
    // Words in Sensor View
    struct SensorViewWord {
        static let accOn = "accOn".localized
        static let gyrOn = "gyrOn".localized
        static let altitudeOn = "altitudeOn".localized
        static let pressureOn = "pressureOn".localized
        static let internetOn = "internetOn".localized
    }
    
    // Words in Menu View
    struct MenuViewWord {
        static let whatToDoLabel = "whatToDoLabel".localized
        static let whatToDoButton = "whatToDoButton".localized
        static let precautionLabel = "precautionLabel".localized
        static let precautionButton = "precautionButton".localized
        static let contactLabel = "contactLabel".localized
        static let contactButton = "contactButton".localized
        static let registerLabel = "registerLabel".localized
        static let registerButton = "registerButton".localized
        static let surveyLabel = "surveyLabel".localized
        static let surveyButton = "surveyButton".localized
        static let logOutWarning = "logOutWarning".localized
        static let logOutButton = "logOutButton".localized
        static let notYetUploaded = "notYetUploaded".localized
        static let uploadCompleted = "uploadCompleted".localized
        static let uploadDataButton = "uploadDataButton".localized
    }
    
    // Words in UserInfoView
    struct SignInViewWord {
        static let signInLabel = "signInLabel".localized
        static let signInPlaceHolder = "signInPlaceHolder".localized
        static let signInButton = "signInButton".localized
    }
    
    // Words in AlertControllers
    struct AlertWord {
        static let onlyNumber = "onlyNumber".localized
        static let typeAgain = "typeAgain".localized
        static let IDLength3 = "IDLength3".localized
        static let signInComplete = "signInComplete".localized
        static let reStartRequest = "reStartRequest".localized
        static let wantToOpenWeb = "wantToOpenWeb".localized
        static let wantToLogOut = "wantToLogOut".localized
        static let canNotCollectData = "canNotCollectData".localized
        static let reallySingOut = "reallySingOut".localized
        static let signOutWhenYouChangeID = "signOutWhenYouChangeID".localized
        static let uploadTomorrow = "uploadTomorrow".localized
//        static let uploadTomorrowMessage = "uploadTomorrowMessage".localized
        static let alreadyUploaded = "alreadyUploaded".localized
        static let uploadComplete = "uploadComplete".localized
        static let internetError = "internetError".localized
        static let internetErrorMessage = "internetErrorMessage".localized
        static let alertCancel = "alertCancel".localized
        static let alertConfirm = "alertConfirm".localized
        static let alertLogOut = "alertLogOut".localized
    }
    
    // Words in Notification
    struct NotiWord {
        static let appOpen = "appOpen".localized
        static let cantCheckData = "cantCheckData".localized
        static let surveyTime = "surveyTime".localized
        static let finishSurvery = "finishSurvey".localized
        static let uploadHealthPlz = "uploadHealthPlz".localized
        static let pushButtonToUpload = "pushButtonToUpload".localized
    }
    
}
