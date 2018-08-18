//
//  ChatViewController.swift
//  BookSwap
//
//  Created by David Shapiro on 8/15/18.
//  Copyright © 2018 David Shapiro. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import SVProgressHUD

class ChatViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    //reference to inputTextField
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    class chatObject: NSObject {
        var sender: String?
        var message: String?
        var date: String?
    }
    
    let cellId = "cellId"
    let bookForSale: Book = selectedBook
    var chatId = ""
    var chats = [chatObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //clearing global variable
        selectedBook = Book()
        
        if selectedChat != "" {
            chatId = selectedChat
            selectedChat = ""
            getHistory()
        }else{
            
            //check if users have previous chat in database
            myDatabase.child("messages").observeSingleEvent(of: .value) { (snapshot) in
                
                for child in snapshot.children {
                    let data = child as! DataSnapshot
                    
                    if data.key == "\(self.bookForSale.listedBy!)-\(userID!)" || data.key == "\(userID!)-\(self.bookForSale.listedBy!)" {
                        self.chatId = data.key as String
                        break
                    }
                }
                //if they don't, create a node for one
                if self.chatId == "" {
                    myDatabase.child("messages").child("\(userID!)-\(self.bookForSale.listedBy!)").childByAutoId().setValue(["message": "specificBookswapPlaceholder", "sender": "placeholder", "date": "placeholder"])
                    self.chatId = "\(userID!)-\(self.bookForSale.listedBy!)"
                    
                    //also create reference to chat under each user's node
                    myDatabase.child("users").child(userID!).child("userChats").child(self.chatId).setValue(self.chatId)
                    myDatabase.child("users").child(self.bookForSale.listedBy!).child("userChats").child(self.chatId).setValue(self.chatId)
                }
                self.getHistory()
            }
        }
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
    }
    
    lazy var inputContainerView: UIView = {

        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //send button anchors
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        //inputTextField anchors
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor.lightGray
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLineView)
        //seperator line anchors
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        //move view up by keyboard height
        containerViewBottomAnchor?.constant = -keyboardRect.height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        containerViewBottomAnchor?.constant = 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chats.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let chat = chats[indexPath.row]
        cell.textView.text = chat.message
        
        //get estimated cell width
        cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: chat.message!).width + 20
        
        setupCell(cell: cell, chat: chat)
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, chat: chatObject) {
        if chat.sender == userID {
            cell.bubbleView.backgroundColor = chatGreen
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
        }else{
            cell.bubbleView.backgroundColor = chatTan
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height:CGFloat = 80
        
        //get estimated height
        if let text = chats[indexPath.item].message {
            height = estimatedFrameForText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimatedFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    @objc func handleSend() {
        
        if inputTextField.text == "" { return }
        
        //add new message data to database under childByAutoId
        var history = myDatabase
        history = myDatabase.child("messages").child(chatId)
        let contents = ["sender":"\(userID!)", "message": inputTextField.text!, "date": "\(Date())"]
        inputTextField.text = ""
        history.childByAutoId().setValue(contents)
    }
    
    func getHistory() {
        myDatabase.child("messages").child(chatId).observe(.value) { (snapshot) in
            self.chats.removeAll()
            for child in snapshot.children {
                let text = child as! DataSnapshot
                let data = text.value as! [String:String]
                let thisChat = chatObject()
                thisChat.message = data["message"]!
                thisChat.sender = data["sender"]!
                thisChat.date = data["date"]!
                //do not show initial database placeholder value
                if thisChat.message != "specificBookswapPlaceholder" {
                    self.chats.append(thisChat)
                    self.collectionView?.reloadData()
                }
            }
            self.scrollToBottom()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    private func scrollToBottom() {
        
        if chats.isEmpty == true { return }
        
        let lastSectionIndex = (collectionView?.numberOfSections)! - 1
        let lastItemIndex = (collectionView?.numberOfItems(inSection: lastSectionIndex))! - 1
        let indexPath = NSIndexPath(item: lastItemIndex, section: lastSectionIndex)
        
        collectionView!.scrollToItem(at: indexPath as IndexPath, at: UICollectionViewScrollPosition.bottom, animated: false)
    }
}





















