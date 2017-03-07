//
//  ChatMessageCell.swift
//  AnyOne
//
//  Created by Samarth Paboowal on 22/12/16.
//  Copyright © 2016 Junkie Labs. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    let textView = UITextView()
    let bubbleView = UIView()
    let profileImage = UIImageView()
    let messageImageView = UIImageView()
    let playButton = UIButton(type: .system)
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    
    var message: Message?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bubbleView.backgroundColor = UIColor(red: 0/255, green: 137/255, blue: 249/255, alpha: 1.0)
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.masksToBounds = true
        addSubview(bubbleView)
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleRightAnchor?.isActive = true
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 8)
        bubbleLeftAnchor?.isActive = false
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.white
        addSubview(textView)
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = translatesAutoresizingMaskIntoConstraints
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = translatesAutoresizingMaskIntoConstraints
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        profileImage.image = UIImage(named: "profile")
        profileImage.contentMode = .scaleAspectFill
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        addSubview(profileImage)
        profileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 32).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImage.layer.cornerRadius = 16
        profileImage.layer.masksToBounds = true
        
        messageImageView.contentMode = .scaleAspectFill
        //messageImageView.backgroundColor = UIColor.brown
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.layer.cornerRadius = 16
        messageImageView.layer.masksToBounds = true
        bubbleView.addSubview(messageImageView)
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        messageImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        messageImageView.isUserInteractionEnabled = true
        
        let image = UIImage(named: "play")
        playButton.setImage(image, for: .normal)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.tintColor = UIColor.white
        bubbleView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.hidesWhenStopped = true
    }
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    func playVideo() {
        
        if let videoURL = message?.videoURL {
            
            let url = URL(string: videoURL)
            player = AVPlayer(url: url!)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            activityIndicator.startAnimating()
            playButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        activityIndicator.stopAnimating()
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        
        if message?.videoURL != nil {
            return
        }
        
        let startingImageView = tapGesture.view as? UIImageView
        
        startingFrame = startingImageView?.superview?.convert((startingImageView?.frame)!, to: nil)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = startingImageView?.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                
                let newHeight = (self.startingFrame?.height)! * keyWindow.frame.width / (self.startingFrame?.width)!
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: newHeight)
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        if let zoomOutImageView = tapGesture.view {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            }, completion: { (completed: Bool) in
                
                zoomOutImageView.removeFromSuperview()
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
