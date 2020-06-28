//
//  PAMicrophonePermissionsCheck.swift
//  PAPermissionsApp
//
//  Created by Pasquale Ambrosini on 06/09/16.
//  Copyright © 2016 Pasquale Ambrosini. All rights reserved.
//

import UIKit
import AVFoundation

public class PAMicrophonePermissionsCheck: PAPermissionsCheck {

	let audioSession = AVAudioSession.sharedInstance()
	
	public override func checkStatus() {
		let currentStatus = self.status

		if AVAudioSession.sharedInstance().isInputAvailable {
			let permission = AVAudioSession.sharedInstance().recordPermission
			switch permission {
			case .granted:
				self.status = .enabled
			case .denied:
				self.status = .disabled
			case .undetermined:
				self.status = .disabled
			@unknown default:
				self.status = .disabled
			}
			
		}else{
			self.status = .unavailable
		}
		
		if self.status != currentStatus {
			self.updateStatus()
		}
	}
	
	public override func defaultAction() {
		if AVAudioSession.sharedInstance().recordPermission == .denied {
			self.openSettings()
		}else{
			AVAudioSession.sharedInstance().requestRecordPermission { (result) in
				if result {
					self.status = .enabled
				}else{
					self.status = .denied
				}
				
				self.updateStatus()
			}
		}
	}
}
