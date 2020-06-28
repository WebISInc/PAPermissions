//
//  PAPermissionsListView.swift
//  PAPermissionsApp
//
//  Created by Pasquale Ambrosini on 05/09/16.
//  Copyright © 2016 Pasquale Ambrosini. All rights reserved.
//
import UIKit

public let PAPermissionDefaultReason = "PAPermissionDefaultReason"

protocol PAPermissionsViewDataSource {
	func permissionsView(_ view: PAPermissionsView, isPermissionEnabled permission: PAPermissionsItem) -> PAPermissionsStatus
	func permissionsView(_ view: PAPermissionsView, checkStatus permission: PAPermissionsItem)
}

protocol PAPermissionsViewDelegate {
	func permissionsView(_ view: PAPermissionsView, permissionSelected permission: PAPermissionsItem)
}

public enum PAPermissionsStatus: Int {
	case disabled
	case enabled
	case checking
	case unavailable
	case denied
}

public enum PAPermissionsType: String {
	case calendar = "calendar"
	case reminders = "reminders"
	case contacts = "contacts"
	case bluetooth = "bluetooth"
	case location = "location"
	case notifications = "notifications"
	case microphone = "microphone"
	case motionFitness = "motion fitness"
	case camera = "camera"
	case siri = "siri"
	case custom = "custom"
	case photoLibrary = "photo library"
	case mediaLibrary = "media library"
}

public class PAPermissionsItem {
	var type: PAPermissionsType
	var identifier: String
	var title: String
	var reason: String
	var icon: UIImage?
	var canBeDisabled: Bool
	
	public init(type: PAPermissionsType, identifier: String, title: String, reason: String, icon: UIImage?, canBeDisabled: Bool) {
		self.type = type
		self.identifier = identifier
		self.title = title
		self.reason = reason
		self.icon = icon
		self.canBeDisabled = canBeDisabled
	}

	public class func reasonText(_ type: PAPermissionsType) -> String {

		var key = ""

		switch type {
		case .bluetooth: key = Constants.InfoPlistKeys.bluetooth
		case .microphone: key = Constants.InfoPlistKeys.microphone
		case .camera: key = Constants.InfoPlistKeys.camera
		case .calendar: key = Constants.InfoPlistKeys.calendar
		case .reminders: key = Constants.InfoPlistKeys.reminders
		case .contacts: key = Constants.InfoPlistKeys.contacts
		case .siri: key = Constants.InfoPlistKeys.siri
		case .motionFitness: key = Constants.InfoPlistKeys.motionFitness
		case .photoLibrary: key = Constants.InfoPlistKeys.photoLibrary
		case .mediaLibrary: key = Constants.InfoPlistKeys.mediaLibrary
		case .location:
			if let _ = Bundle.main.object(forInfoDictionaryKey: Constants.InfoPlistKeys.locationAlways) {
				key = Constants.InfoPlistKeys.locationAlways
			} else {
				key = Constants.InfoPlistKeys.locationWhenInUse
			}
		default:
			break
		}

		if key.isEmpty { return "" }
		return NSLocalizedString(key, tableName: "InfoPlist", bundle: Bundle.main, value: "", comment: "")
	}
	

	public class func itemForType(_ type: PAPermissionsType, reason: String?) -> PAPermissionsItem? {

		var localReason = ""
		if let reason = reason {
			if reason == PAPermissionDefaultReason {
				localReason = reasonText(type)
			}
			else {
				localReason = reason
			}
		}

		switch type {
		case .bluetooth:
			return PAPermissionsItem(type: type, identifier: type.rawValue, title: NSLocalizedString("Bluetooth", comment: ""), reason: localReason, icon: UIImage(named: "pa_bluetooth_icon"), canBeDisabled: false)
		case .location:
			return PAPermissionsItem(type: type, identifier: type.rawValue, title: NSLocalizedString("Location", comment: ""), reason: localReason, icon: UIImage(named: "pa_location_icon"), canBeDisabled: false)
		case .notifications:
			return PAPermissionsItem(type: type, identifier: type.rawValue, title: NSLocalizedString("Notifications", comment: ""), reason: localReason, icon: UIImage(named: "pa_notification_icon"), canBeDisabled: false)
		case .microphone:
			return PAPermissionsItem(type: type, identifier: type.rawValue, title: NSLocalizedString("Microphone", comment: ""), reason: localReason, icon: UIImage(named: "pa_microphone_icon"), canBeDisabled: false)
		case .motionFitness:
			return PAPermissionsItem(type: type, identifier: type.rawValue, title: NSLocalizedString("Motion Fitness", comment: ""), reason: localReason, icon: UIImage(named: "pa_motion_activity_icon"), canBeDisabled: false)
		case .camera:
			return PAPermissionsItem(type: type, identifier: type.rawValue, title: NSLocalizedString("Camera", comment: ""), reason: localReason, icon: UIImage(named: "pa_camera_icon"), canBeDisabled: false)
		case .calendar:
			return PAPermissionsItem(type: type, identifier: type.rawValue, title: NSLocalizedString("Calendar", comment: ""), reason: localReason, icon: UIImage(named: "pa_calendar_icon"), canBeDisabled: false)
		case .reminders:
			return PAPermissionsItem(type: type, identifier: type.rawValue, title: NSLocalizedString("Reminders", comment: ""), reason: localReason, icon: UIImage(named: "pa_reminders_icon"), canBeDisabled: false)
		case .contacts:
			return PAPermissionsItem(type: type, identifier: type.rawValue, title: NSLocalizedString("Contacts", comment: ""), reason: localReason, icon: UIImage(named: "pa_contacts_icon"), canBeDisabled: false)
		case .siri:
			return PAPermissionsItem(type: type, identifier: type.rawValue, title: "Siri", reason: localReason, icon: UIImage(named: "pa_siri_icon.png")!, canBeDisabled: false)
		case .photoLibrary:
			return PAPermissionsItem(type: type, identifier: type.rawValue, title: NSLocalizedString("Photo Library", comment: ""), reason: localReason, icon: UIImage(named: "pa_photo_library_icon"), canBeDisabled: false)
		case .mediaLibrary:
            return PAPermissionsItem(type: type, identifier: type.rawValue, title: NSLocalizedString("Media Library", comment: ""), reason: localReason, icon: UIImage(named: "pa_media_library_icon"), canBeDisabled: false)
		default:
			return nil
		}
	}
}

class PAPermissionsView: UIView, UITableViewDataSource, UITableViewDelegate {

	let titleLabel: UILabel = UILabel()
	let detailsLabel: UILabel = UILabel()
	let continueButton: UIButton = UIButton(type: .system)
	
	var delegate: PAPermissionsViewDelegate?
	var dataSource: PAPermissionsViewDataSource?
	
	fileprivate let tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
	fileprivate let imageView: UIImageView = UIImageView()

	fileprivate var blurEffectView: UIVisualEffectView?
	
	var permissions: [PAPermissionsItem] = Array()
	
	var backgroundImage: UIImage? {
		get {
			return self.imageView.image
		}
		
		set(image) {
			self.imageView.image = image
		}
	}
	
	var useBlurBackground: Bool {
		get {
			return self.blurEffectView != nil
		}
		
		set (use) {
			if use {
				if !self.useBlurBackground {
					let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
					let blurEffectView = UIVisualEffectView(effect: blurEffect)
					blurEffectView.frame = self.bounds
					blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
					self.blurEffectView = blurEffectView
					self.insertSubview(blurEffectView, aboveSubview: self.imageView)
				}
			}else{
				if self.useBlurBackground {
					if let blurEffectView = self.blurEffectView {
						blurEffectView.removeFromSuperview()
						self.blurEffectView = nil
					}
				}
			}
		}
		
	}
	
	override var tintColor: UIColor! {
		get {
			return super.tintColor
		}
		set(newTintColor) {
			super.tintColor = newTintColor
			self.updateTintColor()
		}
	}
	
	// Fonts that can be optionally overridden
	var tableCellTitleFont: UIFont?
	var tableCellDetailsFont: UIFont?
	var tableCellButtonFont: UIFont?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func reloadPermissions() {
		self.tableView.reloadData()
	}
	
	
	//MARK: UI Methods
	
	fileprivate func updateTintColor() {
		self.setupTitleLabel()
		self.setupDetailsLabel()
		self.setupTableView()
		self.setupContinueButton()
		self.tableView.reloadData()
	}
	
	fileprivate func setupUI() {
		self.backgroundColor = UIColor.black
		self.setupImageView()
		self.setupTitleLabel()
		self.setupDetailsLabel()
		self.setupTableView()
		self.setupContinueButton()
		
		let horizontalSpace = 10
		let views = ["titleLabel": self.titleLabel,
					 "detailsLabel": self.detailsLabel,
					 "tableView": self.tableView,
					 "continueButton": self.continueButton] as [String : UIView]
		
		func horizontalConstraints(_ name: String) -> [NSLayoutConstraint]{
			return NSLayoutConstraint.constraints(
				withVisualFormat: "H:|-\(horizontalSpace)-[\(name)]-\(horizontalSpace)-|",
				options: [],
				metrics: nil,
				views: views)
		}
		
		var allConstraints = [NSLayoutConstraint]()
		let verticalConstraints = NSLayoutConstraint.constraints(
			withVisualFormat: "V:|-58-[titleLabel(43)]-30-[detailsLabel]-15-[tableView]-10-[continueButton(30)]-20-|",
			options: [],
			metrics: nil,
			views: views)
		allConstraints.append(contentsOf: verticalConstraints)
		allConstraints.append(contentsOf: horizontalConstraints("titleLabel"))
		allConstraints.append(contentsOf: horizontalConstraints("detailsLabel"))
		allConstraints.append(contentsOf: horizontalConstraints("tableView"))
		allConstraints.append(contentsOf: horizontalConstraints("continueButton"))
		NSLayoutConstraint.activate(allConstraints)
	}
	
	fileprivate func setupTitleLabel() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(titleLabel)
		self.titleLabel.text = "Title"
		self.titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 30)
		self.titleLabel.minimumScaleFactor = 0.1
		self.titleLabel.textColor = self.tintColor
	}
	
	fileprivate func setupDetailsLabel() {
		detailsLabel.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(detailsLabel)
		self.detailsLabel.text = "Details"
		// handle multi line details text
		self.detailsLabel.numberOfLines = 0
		self.detailsLabel.lineBreakMode = .byWordWrapping
		self.detailsLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15)
		self.detailsLabel.minimumScaleFactor = 0.1
		self.detailsLabel.textColor = self.tintColor
	}
	
	fileprivate func setupTableView() {
		tableView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(tableView)
		self.tableView.backgroundColor = UIColor.clear
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.estimatedRowHeight = 50.0
		self.tableView.register(PAPermissionsTableViewCell.self, forCellReuseIdentifier: "permission-item")
		self.tableView.tableFooterView = UIView()
		
		let refreshControl: UIRefreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(PAPermissionsView.refresh(_:)), for: UIControl.Event.valueChanged)
		tableView.addSubview(refreshControl)
		refreshControl.tintColor = self.tintColor
	}
	
	@objc fileprivate func refresh(_ sender:UIRefreshControl) {
		sender.endRefreshing()
		for permission in self.permissions {
			self.dataSource?.permissionsView(self, checkStatus: permission)
		}
	}
	
	fileprivate func setupContinueButton() {
		continueButton.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(continueButton)
		self.continueButton.backgroundColor = UIColor.red
		self.continueButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 14)
		self.continueButton.titleLabel?.minimumScaleFactor = 0.1
		self.continueButton.setTitle(NSLocalizedString("Continue", comment: ""), for: UIControl.State())
		self.continueButton.setTitleColor(self.tintColor, for: UIControl.State())
		self.continueButton.backgroundColor = UIColor.clear
	}
	
	fileprivate func setupImageView() {
		imageView.contentMode = .scaleAspectFill
		self.addSubview(imageView)
		self.imageView.backgroundColor = UIColor.clear
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: [], metrics: nil, views: ["subview": imageView]))
		imageView.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: [], metrics: nil, views: ["subview": imageView]))
	}
	
	
	//MARK: Table View Methods
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.permissions.count
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "permission-item", for: indexPath) as! PAPermissionsTableViewCell
		let item = self.permissions[(indexPath as NSIndexPath).row]
		cell.didSelectItem = {selectedPermission in
			if let delegate = self.delegate {
				delegate.permissionsView(self, permissionSelected: selectedPermission)
			}
		}
		cell.permission = item
		cell.permissionStatus = self.dataSource!.permissionsView(self, isPermissionEnabled: item)
		cell.tintColor = self.tintColor
		cell.selectionStyle = .none
		cell.titleLabel.text = item.title
		cell.detailsLabel.text = item.reason
		cell.iconImageView.image = item.icon?.withRenderingMode(.alwaysTemplate)
		cell.permission = item
		if let font = tableCellTitleFont {
			cell.titleFont = font
		}
		
		if let font = tableCellDetailsFont {
			cell.detailsFont = font
		}
		
		if let font = tableCellButtonFont {
			cell.buttonFont = font
		}
		
		return cell
	}
}
