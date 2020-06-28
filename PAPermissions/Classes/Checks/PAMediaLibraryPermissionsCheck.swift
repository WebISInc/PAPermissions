//
//  PAMediaLibraryPermissionsCheck.swift
//  Pods
//
//  Created by Tom Major on 10/04/17.
//  template taken from PAPhotoLibraryPermissionsCheck.swift
//
//

import UIKit
import MediaPlayer

public class PAMediaLibraryPermissionsCheck: PAPermissionsCheck {
    
    public override func checkStatus() {
        let currentStatus = self.status
        self.updatePermissions(status: MPMediaLibrary.authorizationStatus())
        
        if self.status != currentStatus {
            self.updateStatus()
        }
    }
    
    public override func defaultAction() {
        MPMediaLibrary.requestAuthorization({ (result) in
			self.updatePermissions(status: result)
			self.updateStatus()
		})
    }
    
    private func updatePermissions(status: MPMediaLibraryAuthorizationStatus) {
		
		let oldStatus = self.status
		
        switch status {
        case .authorized:
            self.status = .enabled
		case .denied:
			self.status = .denied
		case .notDetermined:
			self.status = .disabled
        case .restricted:
            self.status = .unavailable
		@unknown default:
			self.status = .disabled
		}
		
		if oldStatus == .denied && self.status == .denied {
			self.openSettings()
		}
    }
    
}
