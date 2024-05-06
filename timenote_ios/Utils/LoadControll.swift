//
//  LoadControll.swift
//  Timenote
//
//  Created by Aziz Essid on 8/27/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import UIKit
import Foundation

public class UILoadControl: UIControl {
    
    fileprivate var activityIndicatorView: UIActivityIndicatorView!
    private var originalDelegate: UIScrollViewDelegate?
    
    internal var target: AnyObject?
    internal var action: Selector!
    
    public var heightLimit: CGFloat = 150.0
    public fileprivate (set) var loading: Bool = false
    
    public var scrollView: UIScrollView = UIScrollView()
    override public var frame: CGRect {
        didSet{
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    public init(target: AnyObject?, action: Selector) {
        self.init()
        self.initialize()
        self.target = target
        self.action = action
        addTarget(self.target, action: self.action, for: .valueChanged)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    /*
     Update layout at finsih to load
     */
    public func endLoading(){
        self.setLoading(isLoading: false)
        self.fixPosition()
    }
    
    public func update() {
        updateUI(scrollView: self.scrollView)
    }
}

extension UILoadControl {
    
    /*
     Initilize the control
     */
    fileprivate func initialize(){
        self.addTarget(self, action: #selector(UILoadControl.didValueChange(sender:)), for: .valueChanged)
        setupActivityIndicator()
    }
    
    /*
     Check if the control frame should be updated.
     This method is called after user hits the end of the scrollView
     */
    func updateUI(scrollView : UIScrollView, _ endDraging : Bool = false, _ beginDraging: Bool = false){
        guard !loading else { return }
        let difference = (scrollView.contentOffset.y + scrollView.frame.size.height) - scrollView.contentSize.height
        if (difference >= 0 && !loading) || (difference >= heightLimit && loading) {
            self.updateFrame(rect: CGRect(x:0.0, y:scrollView.contentSize.height, width:scrollView.frame.size.width, height: difference), endDraging, beginDraging)
        }
    }
    
    /*
     Update layout after user scroll the scrollView
     */
    private func updateFrame(rect: CGRect, _ endDraging : Bool = false, _ beginDraging: Bool = false){
        DispatchQueue.main.async {
            guard let superview = self.superview else {
                return
            }            
            superview.frame = rect
            self.frame = superview.bounds
            self.activityIndicatorView.alpha = (((self.frame.size.height * 100) / self.heightLimit) / 100)
            self.activityIndicatorView.center = CGPoint(x:(self.frame.size.width / 2), y:(self.frame.size.height / 2))
            let difference = (self.scrollView.contentOffset.y + self.scrollView.frame.size.height) - self.scrollView.contentSize.height
            if beginDraging && difference > 0 {
                self.activityIndicatorView.isHidden = false
            }
            if endDraging && (difference > self.heightLimit) && !self.loading {
                self.activityIndicatorView.isHidden = false
                self.setLoading(isLoading: true)
                self.sendActions(for: UIControl.Event.valueChanged)
            } else if endDraging && !self.loading {
                self.fixPosition()
            }
        }
    }
    
    /*
     Place control at the scrollView bottom
     */
    fileprivate func fixPosition(){
        self.activityIndicatorView.isHidden = true
        self.updateFrame(rect: CGRect(x:0.0, y:scrollView.contentSize.height, width:scrollView.frame.size.width, height: -1))
    }
    
    /*
     Set layout to a "loading" or "not loading" state
     */
    fileprivate func setLoading(isLoading: Bool){
        loading = isLoading
        DispatchQueue.main.async { [unowned self] in
            
            var contentInset = self.scrollView.contentInset
            
            if self.loading {
                contentInset.bottom = self.heightLimit
            }else{
                contentInset.bottom = 0.0
            }
            
            self.scrollView.contentInset = contentInset
        }
    }
    
    /*
     Prepare activityIndicator
     */
    private func setupActivityIndicator(){
        
        if self.activityIndicatorView != nil {
            return
        }
        
        self.activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        self.activityIndicatorView.hidesWhenStopped = true
        self.activityIndicatorView.color = UIColor.darkGray
        self.activityIndicatorView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        self.activityIndicatorView.clipsToBounds = true
        self.activityIndicatorView.startAnimating()
        
        addSubview(self.activityIndicatorView)
        bringSubviewToFront(self.activityIndicatorView)
    }
    
    @objc fileprivate func didValueChange(sender: AnyObject?){
        setLoading(isLoading: true)
    }
    
}

extension UIScrollView {
    
    /*
     Add new variables to UIScrollView class
     
     UIControls can only be placed as subviews of UITableView.
     So we had to place UILoadControl inside a UIView "loadControlView" and place "loadControlView" as a subview of UIScrollView.
     */
    
    private struct AssociatedKeys {
        static var delegate: UIScrollViewDelegate?
        static var loadControl: UILoadControl?
        fileprivate static var loadControlView: UIView?
    }
    
    /*
     UILoadControl object
     */
    public var loadControl: UILoadControl? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.loadControl) as? UILoadControl
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.loadControl, newValue as UILoadControl?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.updateLoadControl()
            }
        }
    }
    
    /*
     UILoadControl view containers
     */
    fileprivate var loadControlView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.loadControlView) as? UIView
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.loadControlView, newValue as UIView?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

extension UIScrollView {
    
    public func setValue(value: AnyObject?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
    
    fileprivate func updateLoadControl() {
        guard let loadControl = self.loadControl else {
            return
        }
        
        loadControl.scrollView = self
        return setupLoadControlViewWithControl(control: loadControl)
    }
    
    
    fileprivate func setupLoadControlViewWithControl(control: UILoadControl) {
        
        guard let loadControlView = self.loadControlView else {
            self.loadControlView = UIView()
            self.loadControlView?.clipsToBounds = true
            self.loadControlView?.addSubview(control)
            return addSubview(self.loadControlView!)
        }
        
        if loadControlView.subviews.contains(control) {
            return
        }
        
        return loadControlView.addSubview(control)
    }
    
    
}

