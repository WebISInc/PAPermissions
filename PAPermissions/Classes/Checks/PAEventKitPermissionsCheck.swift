//
//  PARemindersPermissionsCheck.swift
//  PAPermissionsApp
//
//  Created by Pasquale Ambrosini on 9/13/16.
//  Copyright © 2016 Pasquale Ambrosini. All rights reserved.
//

import UIKit
import EventKit

public class PACalendarPermissionsCheck: PAEKPermissionsCheck {
	public override init() {
		super.init()
		entityType = .event
	}
}

public class PARemindersPermissionsCheck: PAEKPermissionsCheck {
	public override init() {
		super.init()
		entityType = .reminder
	}
}

public class PAEKPermissionsCheck: PAPermissionsCheck {

	var entityType : EKEntityType?

	public override func checkStatus() {
		guard let entityType = entityType else {
			return
		}
		
		let currentStatus = status

		switch EKEventStore.authorizationStatus(for: entityType) {
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

	public override func defaultAction() {
		guard let entityType = entityType else {
			return
		}
		
		let status = EKEventStore.authorizationStatus(for: entityType)
		if status == .denied {
			self.openSettings()
		} else {
			EKEventStore().requestAccess(to: entityType, completion: { (success, error) in
				if success && error == nil {
					self.status = .enabled
				} else {
					self.status = .denied
				}
				self.updateStatus()
			})
		}
		
	}

}


