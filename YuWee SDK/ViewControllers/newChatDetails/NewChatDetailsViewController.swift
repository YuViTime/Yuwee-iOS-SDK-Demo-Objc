//
//  ChatDetailsViewController.swift
//  YuWee SDK
//
//  Created by Tanay on 16/02/21.
//  Copyright © 2021 Prasanna Gupta. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SwiftyJSON


struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var json: JSON?
}

struct Media:MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
}

@objcMembers
@objc class NewChatDetailsViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate, InputBarAccessoryViewDelegate,
                                          YuWeeNewMessageReceivedDelegate, YuWeeTypingEventDelegate, YuWeeMessageDeliveredDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, YuWeeFileUploadDelegate, YuWeeBroadcastMessageDelegate {

    

    
    let WIDTH = 250, HEIGHT = 200
    
    public var name = ""
    public var roomId = ""
    public var isBroadcast = false
    
    let userId = UserDefaults.init(suiteName: "123")?.object(forKey: "_id") as! String
    let userName = UserDefaults.init(suiteName: "123")?.object(forKey: "name") as! String
    var currentUser : Sender?
    var messagesArray = [MessageType]()
    private var messageCount = 0
    private var isLastPage = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = Sender(senderId: userId, displayName: name)
        
        self.navigationItem.title = name
        let imageOption = UIBarButtonItem(title: "More", style: .done, target: self, action: #selector(showMoreChatOptions))
            navigationItem.setRightBarButton(imageOption, animated: true)
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        getMessages()
        
        Yuwee.sharedInstance().getChatManager().setNewMessageReceivedDelegate(self)
        Yuwee.sharedInstance().getChatManager().setTypingEventDelegate(self)
        Yuwee.sharedInstance().getChatManager().setMessageDeliveredDelegate(self)
        
        Yuwee.sharedInstance().getChatManager().getFileManager().initFileShare(withRoomId: roomId) { (data, isSuccess) in
            print(data!)
        }

    }
    
    @objc func showMoreChatOptions(){
        let alert = UIAlertController(title: "Options", message: "", preferredStyle: .actionSheet)
        
        let chareImage = UIAlertAction(title: "Share Image", style: .default) {
            UIAlertAction in
            self.imageOptionFun()
        }
        alert.addAction(chareImage)
    
        
        let clearChat = UIAlertAction(title: "Clear Chat", style: .default) {
            UIAlertAction in
            self.clearOptionFun()
        }
        alert.addAction(clearChat)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            UIAlertAction in
            // It will dismiss action sheet
        }
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func imageOptionFun(){
        let myImagePicker = UIImagePickerController()
        myImagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        myImagePicker.delegate = self;
        self.navigationController?.present(myImagePicker, animated: true, completion: nil)
    }
    
    func clearOptionFun(){
        Yuwee.sharedInstance().getChatManager().clearChats(forRoomId: roomId) { (isSuccess, data) in
            if isSuccess{
                self.messagesArray.removeAll()
                self.messagesCollectionView.reloadData()
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let pic : NSURL = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerImageURL")] as! NSURL
        print("imagePickerController Pic: \(String(describing: pic.path))")
        
        let data = NSData(contentsOfFile: pic.path!)
        
        Yuwee.sharedInstance().getChatManager().getFileManager().sendFile(withRoomId: roomId, withUniqueIdentifier: UUID.init().uuidString, withFileData: data! as Data, withFileName: UUID().uuidString, withFileExtension: "jpg", withFileSize: 0, with: self)
        
        
        let messageId = UUID().uuidString
        
        //let sender = Sender(senderId: item["sender"]["senderId"].string!, displayName: item["sender"]["name"].string!)
        
        let image = UIImage(named: "AppIcon")
        let myImage = UIImage(contentsOfFile: pic.path!)
        let size = CGSize(width: self.WIDTH, height: self.HEIGHT)
        let media = Media(url: nil, image: myImage, placeholderImage: image!, size: size)
            
            
        let msg = Message(sender: self.currentUser!, messageId: messageId, sentDate: Date(), kind: .photo(media), json: nil)
        
        self.messagesArray.append(msg)
        
        self.messagesCollectionView.insertSections([messagesArray.count - 1])
        self.messagesCollectionView.scrollToBottom()
    

        picker .dismiss(animated: true, completion: nil)
        
    }
    
    func onUploadSuccess() {
        print("onUploadSuccess")
    }
    
    func onUploadStarted() {
        print("onUploadStarted")
    }
    
    func onUploadFailed() {
        print("onUploadFailed")
    }
    
    func onProgressUpdate(withProgress progress: Double) {
        print("onProgressUpdate: \(progress)")
    }
    
    
    private func getMessages(){
        if isLastPage {
            return
        }
        Yuwee.sharedInstance().getChatManager().fetchChatMessages(forRoomId: roomId, totalMessagesCountToSkip: messageCount) { (isSuccess, data) in
            
            if !isSuccess {
                return
            }
            
            let json = JSON(data!)
            print(json)
            let messages = json["result"]["messages"]
            if messages.count < 20{
                self.isLastPage = true
            }
            
            if messages.isEmpty{
                self.isLastPage = true
                return
            }
            
            var pageArray = [MessageType]()
            if let items = messages.array {
                for item in items {
                    
                    let messageId = item["messageId"].string
                    let message = item["message"].string
                    let dateOfCreation = item["dateOfCreation"].double
                    let messageType = item["messageType"].string
                    
                    let quotedMessage = item["quotedMessage"]
                    
                    var quotedMsg : String? = nil
                    
                    if (!quotedMessage.isEmpty){
                        //print("Quoted Message: \(quotedMessage)" )
                        quotedMsg = quotedMessage["content"].string
                    }
                    
                    let date = Date(timeIntervalSince1970: (dateOfCreation! / 1000.0))
                    
                    let sender = Sender(senderId: item["sender"]["_id"].string!, displayName: item["sender"]["name"].string!)
                    
                    var msg: Message!
                    if (messageType!.caseInsensitiveCompare("file") == .orderedSame) {
                        
                        let image = UIImage(named: "AppIcon")
                        
                        let size = CGSize(width: self.WIDTH, height: self.HEIGHT)
                        
                        let media = Media(url: nil, image: nil, placeholderImage: image!, size: size)
                        
                        
                        msg = Message(sender: sender, messageId: messageId!, sentDate: date, kind: .photo(media), json: item)
                    }
                    else if (messageType!.caseInsensitiveCompare("text") == .orderedSame){
                        
                        var mm = message
                        if quotedMsg != nil {
                            mm = "Quote: " + quotedMsg! + "\n\n" + message!
                        }
                        
                        msg = Message(sender: sender, messageId: messageId!, sentDate: date, kind: .text(mm!), json: item)
                    }
                    else if (messageType!.caseInsensitiveCompare("call") == .orderedSame){
                        msg = Message(sender: sender, messageId: messageId!, sentDate: date, kind: .text("Call"), json: item)
                    }
                    
                    if self.messageCount == 0 {
                        self.messagesArray.append(msg)
                    }
                    else {
                        pageArray.append(msg)
                    }
                    
                    
                }
            }
            
            
            if self.messageCount == 0 {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
            else {
                pageArray.reverse()
                for item in pageArray{
                    self.messagesArray.insert(item, at: 0)
                    self.messagesCollectionView.insertSections([0])
                }
            }
            self.messageCount = self.messageCount + 20
        }
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 30
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let paragraphStyle = NSMutableParagraphStyle()
        if message.sender.senderId == currentUser?.senderId {
                paragraphStyle.alignment = NSTextAlignment.right
            }
            else{
                paragraphStyle.alignment = NSTextAlignment.left
            }
        
        let name = message.sender.displayName
            return NSAttributedString(
              string: name,
              attributes: [
                .font: UIFont.preferredFont(forTextStyle: .title3),
                .foregroundColor: UIColor(white: 0.3, alpha: 1),
                .paragraphStyle:paragraphStyle
              ]
            )
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let paragraphStyle = NSMutableParagraphStyle()
        if message.sender.senderId == currentUser?.senderId {
                paragraphStyle.alignment = NSTextAlignment.right
            }
            else{
                paragraphStyle.alignment = NSTextAlignment.left
            }
        
        let date = message.sentDate
        
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let myString = formatter.string(from: date) // string purpose I add here
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "dd-MM HH:mm:ss"
        // again convert your date to string
        let myStringafd = formatter.string(from: yourDate!)
        
        
        
            return NSAttributedString(
                string: myStringafd,
              attributes: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor(white: 0.3, alpha: 1),
                .paragraphStyle:paragraphStyle
              ]
            )
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 30
    }

    func currentSender() -> SenderType {
        return currentUser!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messagesArray[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messagesArray.count
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        print("didPressSendButtonWith \(isBroadcast)")
        
        let uuid = UUID().uuidString
        
        if isBroadcast {
            Yuwee.sharedInstance().getChatManager().broadcastMessage(withRoomId: roomId, withMessage: text, withUniqueMessageId: UUID().uuidString, with: self)
        }
        else{
            Yuwee.sharedInstance().getChatManager().sendMessage(text, toRoomId: roomId, messageIdentifier: uuid, withQuotedMessageId: nil);
        }

        
        let msg = Message(sender: self.currentUser!, messageId: uuid, sentDate: Date(), kind: .text(text), json: nil)

        inputBar.inputTextView.text = String()
        self.messagesArray.append(msg)
  
        self.messagesCollectionView.insertSections([messagesArray.count - 1])
        self.messagesCollectionView.scrollToBottom()
        
    }
    
    func onMessageBroadcastSuccess(_ uniqueMessageId: String!) {
        print("onMessageBroadcastSuccess \(uniqueMessageId)")
    }
    
    func onMessageBroadcastError(_ error: String!) {
        print("onMessageBroadcastError \(error)")
    }
    
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        Yuwee.sharedInstance().getChatManager().sendTypingStatus(toRoomId: roomId)
    }
    
    
    func onUserTyping(inRoom dictObject: [AnyHashable : Any]!) {
        let data = JSON(dictObject)
        print("onUserTyping")
        //print(data)
        
        setTypingIndicatorViewHidden(false, animated: true)
        self.messagesCollectionView.scrollToBottom()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.setTypingIndicatorViewHidden(true, animated: true)
            self.messagesCollectionView.scrollToBottom()
        }
        
    }
    
    func onMessageDelivered(_ dictParameter: [AnyHashable : Any]!) {
        let data = JSON(dictParameter)
        print("onMessageDelivered")
        print(data)
    }

    func onNewMessageReceived(_ dictParameter: [AnyHashable : Any]!) {
        let item = JSON(dictParameter)
        print("onNewMessageReceived")
        print(item)
        
        
        let messageId = item["messageId"].string
        let message = item["message"].string
        let messageType = item["messageType"].string
        let dateOfCreation = item["dateOfCreation"].double
        
        let quotedMessage = item["quotedMessage"]
        
        var quotedMsg : String? = nil
        
        if (!quotedMessage.isEmpty){
            //print("Quoted Message: \(quotedMessage)" )
            quotedMsg = quotedMessage["content"].string
        }
        
        let date = Date(timeIntervalSince1970: (dateOfCreation! / 1000.0))
        
        let sender = Sender(senderId: item["sender"]["senderId"].string!, displayName: item["sender"]["name"].string!)
        
        var msg: Message!
        if (messageType!.caseInsensitiveCompare("file") == .orderedSame) {
            
            let image = UIImage(named: "AppIcon")
            
            let size = CGSize(width: self.WIDTH, height: self.HEIGHT)
            
            let media = Media(url: nil, image: nil, placeholderImage: image!, size: size)
            
            
            msg = Message(sender: sender, messageId: messageId!, sentDate: date, kind: .photo(media), json: item)
        }
        else if (messageType!.caseInsensitiveCompare("text") == .orderedSame){
            
            var mm = message
            if quotedMsg != nil {
                mm = "Quote: " + quotedMsg! + "\n\n" + message!
            }
            
            msg = Message(sender: sender, messageId: messageId!, sentDate: date, kind: .text(mm!), json: item)
        }
        else if (messageType!.caseInsensitiveCompare("call") == .orderedSame){
            msg = Message(sender: sender, messageId: messageId!, sentDate: date, kind: .text("Call"), json: item)
        }

        self.messagesArray.append(msg)
        
        self.messagesCollectionView.insertSections([messagesArray.count - 1])
        self.messagesCollectionView.scrollToBottom()
    }
    
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("didTapImage")
        
        let path = messagesCollectionView.indexPath(for: cell)
        //print("ROW: \(path!.section)")
        
        let message : Message = messagesArray[path!.section] as! Message
        let item: JSON = message.json!
        let fileId = item["fileInfo"]["_id"].string
        let fileKey = item["fileInfo"]["fileKey"].string
    
        //print("Data: \(fileId!) : \(fileKey!)")
        
        Yuwee.sharedInstance().getChatManager().getFileManager().getFileUrl(withFileId: fileId!, withFileKey: fileKey!) { (url, isSuccess) in
            print("\(url!)")
            
            let messageId = item["messageId"].string
            let dateOfCreation = item["dateOfCreation"].double
            
            let date = Date(timeIntervalSince1970: (dateOfCreation! / 1000.0))
            
            var sender: Sender!
            if(item["sender"]["_id"].exists()){
                sender = Sender(senderId: item["sender"]["_id"].string!, displayName: item["sender"]["name"].string!)
            }
            else{
                sender = Sender(senderId: item["sender"]["senderId"].string!, displayName: item["sender"]["name"].string!)
            }
            
            
            
            let placeholderImage = UIImage(named: "AppIcon")
            let url = URL(string:url!)
 
            let size = CGSize(width: self.WIDTH, height: self.HEIGHT)
            
            var image: UIImage?
            
            if let data = try? Data(contentsOf: url!){
                image = UIImage(data: data)
            }
            
            let media = Media(url: url, image: image!, placeholderImage: placeholderImage!, size: size)
            
            
            let msg = Message(sender: sender!, messageId: messageId!, sentDate: date, kind: .photo(media), json: item)
            
            self.messagesArray[path!.section] = msg
            
            self.messagesCollectionView.reloadSections([path!.section])
            
        }
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("didTapMessage")
        
        let path = messagesCollectionView.indexPath(for: cell)
        print("ROW: \(path!.section)")
        self.showAction(section: path!.section)
    }
    
    func showAction(section: Int) {
        let message = messagesArray[section]
        
        
        let alert = UIAlertController(title: "Options", message: "", preferredStyle: .actionSheet)
        
        let actionForMe = UIAlertAction(title: "Delete for me", style: .default) {
            UIAlertAction in
            self.deleteMessage(isForMe: true, section: section)
        }
        alert.addAction(actionForMe)
        
        if message.sender.senderId == currentUser?.senderId {
            let actionEveryone = UIAlertAction(title: "Delete for all", style: .default) {
                UIAlertAction in
                self.deleteMessage(isForMe: false, section: section)
            }
            alert.addAction(actionEveryone)
        }
        
        let actionReply = UIAlertAction(title: "Reply", style: .default) {
            UIAlertAction in
            self.showQuoteMessageDialog(section: section)
        }
        alert.addAction(actionReply)
        
        let actionForward = UIAlertAction(title: "Forward", style: .default) {
            UIAlertAction in
            self.forwardMessage(section: section)
        }
        alert.addAction(actionForward)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            UIAlertAction in
            // It will dismiss action sheet
        }
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func deleteMessage(isForMe: Bool, section: Int){
        Yuwee.sharedInstance().getChatManager().deleteMessage(forMessageId: messagesArray[section].messageId, roomId: self.roomId, deleteType: isForMe ? DeleteType.DELETE_FOR_ME : DeleteType.DELETE_FOR_ALL) { (isSuccess, response) in
            let data = JSON(response!)
            print(data)
            if isSuccess{
                self.messagesArray.remove(at: section)
                self.messagesCollectionView.deleteSections([section])
            }
            
        }
    }
    
    private func forwardMessage(section: Int){
        Yuwee.sharedInstance().getChatManager().forwardMessage("Forward Message", withRoomId: self.roomId, withMessageIdentifier: UUID().uuidString)
    }
    
    private func showQuoteMessageDialog(section: Int){
        
        let message: Message = self.messagesArray[section] as! Message
        let json : JSON = message.json!
        let msg = json["message"].string
        let quoteMessageId = json["messageId"].string
        
        let alert = UIAlertController(title: "Quote Message", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter your message"
        })

        alert.addAction(UIAlertAction(title: "Quote", style: .default, handler: { action in

            if let message = alert.textFields?.first?.text {
                self.quoteMessage(message: message, quoteMessageId: quoteMessageId!, quotedMsg: msg!)
            }
        }))

        self.present(alert, animated: true)
    }
    
    private func quoteMessage(message: String, quoteMessageId: String, quotedMsg: String){
        let uuid = UUID().uuidString
        Yuwee.sharedInstance().getChatManager().sendMessage(message, toRoomId: self.roomId, messageIdentifier: uuid, withQuotedMessageId: quoteMessageId)
        
        let concatMessage = "Quote: " + quotedMsg + "\n\n" + message
        
        let msg = Message(sender: self.currentUser!, messageId: uuid, sentDate: Date(), kind: .text(concatMessage), json: nil)
        
        self.messagesArray.append(msg)
  
        self.messagesCollectionView.insertSections([messagesArray.count - 1])
        self.messagesCollectionView.scrollToBottom()
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //print("Position: \(indexPath.section) Message Count: \(self.messageCount) Last Page? \(self.isLastPage)")
        if (self.messageCount != 0 && indexPath.section == 0 && !isLastPage) {
                self.getMessages()
            }
        }

}
