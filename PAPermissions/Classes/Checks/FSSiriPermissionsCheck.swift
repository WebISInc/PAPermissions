//
//  FSSiriPermissionsCheck.swift
//  Universal
//
//  Created by Aleksei Kac on 11/11/17.
//  Copyright © 2017 Fanatic Software, Inc. All rights reserved.
//

import UIKit
import Intents

class FSSiriPermissionsCheck: PAPermissionsCheck {
	override func checkStatus() {
		let currentStatus = status
		
		switch INPreferences.siriAuthorizationStatus() {
		case .authorized:
			status = .enabled
		case .denied:
			status = .disabled
		case .notDetermined:
			status = .disabled
		case .restricted:
			status = .unavailable
		@unknown default:
			status = .disabled
		}
		
		if currentStatus != status {
			updateStatus()
		}
	}
	
	override func defaultAction() {
		
		if INPreferences.siriAuthorizationStatus() == .denied {
			guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
			UIApplication.shared.open(settingsURL, options:convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler:nil)
		} else {
			
			INPreferences.requestSiriAuthorization { status in
				if status == .authorized {
					self.status = .enabled
				} else {
					self.status = .denied
				}
				self.updateStatus()
			}
		}
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
