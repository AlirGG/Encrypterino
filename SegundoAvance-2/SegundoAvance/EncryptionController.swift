//
//  EncryptionController.swift
//  SegundoAvance
//
//  Created by AdrÍan Flores García on 21/03/17.
//  Copyright © 2017 Roberto. All rights reserved.
//

import UIKit

// Singleton instance
private let _singletonInstance = AsymmetricCryptoManager()

// Constants
private let kAsymmetricCryptoManagerApplicationTag = "com.AsymmetricCrypto.keypair"
private let kAsymmetricCryptoManagerKeyType = kSecAttrKeyTypeRSA
private let kAsymmetricCryptoManagerKeySize = 2048
private let kAsymmetricCryptoManagerCypheredBufferSize = 1024
private let kAsymmetricCryptoManagerSecPadding: SecPadding = .PKCS1

enum AsymmetricCryptoException: Error {
    case unknownError
    case duplicateFoundWhileTryingToCreateKey
    case keyNotFound
    case authFailed
    case unableToAddPublicKeyToKeyChain
    case wrongInputDataFormat
    case unableToEncrypt
    case unableToDecrypt
    case unableToSignData
    case unableToVerifySignedData
    case unableToPerformHashOfData
    case unableToGenerateAccessControlWithGivenSecurity
    case outOfMemory
}

class AsymmetricCryptoManager: NSObject {
    
    /** Shared instance */
    class var sharedInstance: AsymmetricCryptoManager {
        return _singletonInstance
    }
    
    
    func createSecureKeyPair(_ completion: ((_ success: Bool, _ error: AsymmetricCryptoException?) -> Void)? = nil) {
        // private key parameters
        let privateKeyParams: [String: AnyObject] = [
            kSecAttrIsPermanent as String: true as AnyObject,
            kSecAttrApplicationTag as String: kAsymmetricCryptoManagerApplicationTag as AnyObject
        ]
        
        //public key parameters
        let publicKeyParams: [String: AnyObject] = [
            kSecAttrIsPermanent as String: true as AnyObject,
            kSecAttrApplicationTag as String: kAsymmetricCryptoManagerApplicationTag as AnyObject
        ]
        
        // global parameters
        let parameters: [String: AnyObject] = [
            kSecAttrKeyType as String:          kAsymmetricCryptoManagerKeyType,
            kSecAttrKeySizeInBits as String:    kAsymmetricCryptoManagerKeySize as AnyObject,
            kSecPublicKeyAttrs as String:       publicKeyParams as AnyObject,
            kSecPrivateKeyAttrs as String:      privateKeyParams as AnyObject,
            ]
        
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            var pubKey, privKey: SecKey?
            let status = SecKeyGeneratePair(parameters as CFDictionary, &pubKey, &privKey)
            
            if status == errSecSuccess {
                DispatchQueue.main.async(execute: { completion?(true, nil) })
            } else {
                var error = AsymmetricCryptoException.unknownError
                switch (status) {
                case errSecDuplicateItem: error = .duplicateFoundWhileTryingToCreateKey
                case errSecItemNotFound: error = .keyNotFound
                case errSecAuthFailed: error = .authFailed
                default: break
                }
                DispatchQueue.main.async(execute: { completion?(false, error) })
            }
        }
    }
    
    func getPublicKeyData() -> Data? {
        let parameters = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: kAsymmetricCryptoManagerApplicationTag,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecReturnData as String: true
            ] as [String : Any]
        var data: AnyObject?
        let status = SecItemCopyMatching(parameters as CFDictionary, &data)
        if status == errSecSuccess {
            return data as? Data
        } else { return nil }
    }
    
    func getPublicKeyReference() -> SecKey? {
        let parameters = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: kAsymmetricCryptoManagerApplicationTag,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecReturnRef as String: true,
            ] as [String : Any]
        var ref: AnyObject?
        let status = SecItemCopyMatching(parameters as CFDictionary, &ref)
        if status == errSecSuccess { return ref as! SecKey? } else { return nil }
    }
    
    func getPrivateKeyReference() -> SecKey? {
        let parameters = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrApplicationTag as String: kAsymmetricCryptoManagerApplicationTag,
            kSecReturnRef as String: true,
            ] as [String : Any]
        var ref: AnyObject?
        let status = SecItemCopyMatching(parameters as CFDictionary, &ref)
        if status == errSecSuccess { return ref as! SecKey? } else { return nil }
    }
    
    func keyPairExists() -> Bool {
        return self.getPublicKeyData() != nil
    }
    
    func deleteSecureKeyPair(_ completion: ((_ success: Bool) -> Void)?) {

        let deleteQuery = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: kAsymmetricCryptoManagerApplicationTag,
            ] as [String : Any]
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            let status = SecItemDelete(deleteQuery as CFDictionary) // delete private key
            DispatchQueue.main.async(execute: { completion?(status == errSecSuccess) })        }
    }
    
    
    func encryptMessageWithPublicKey(_ message: String, completion: @escaping (_ success: Bool, _ data: Data?, _ error: AsymmetricCryptoException?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            
            if let publicKeyRef = self.getPublicKeyReference() {
                //plain text
                guard let messageData = message.data(using: String.Encoding.utf8) else {
                    completion(false, nil, .wrongInputDataFormat)
                    return
                }
                let plainText = (messageData as NSData).bytes.bindMemory(to: UInt8.self, capacity: messageData.count)
                let plainTextLen = messageData.count
                
                var cipherData = Data(count: SecKeyGetBlockSize(publicKeyRef))
                let cipherText = cipherData.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8> in
                    return bytes
                })
                var cipherTextLen = cipherData.count
                
                let status = SecKeyEncrypt(publicKeyRef, .PKCS1, plainText, plainTextLen, cipherText, &cipherTextLen)
                
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(status == errSecSuccess, cipherData, status == errSecSuccess ? nil : .unableToEncrypt)
                    cipherText.deinitialize()
                })
                return
            } else { DispatchQueue.main.async(execute: { completion(false, nil, .keyNotFound) }) }
        }
    }
    
    func decryptMessageWithPrivateKey(_ encryptedData: Data, completion: @escaping (_ success: Bool, _ result: String?, _ error: AsymmetricCryptoException?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            
            if let privateKeyRef = self.getPrivateKeyReference() {
                //plain text
                let encryptedText = (encryptedData as NSData).bytes.bindMemory(to: UInt8.self, capacity: encryptedData.count)
                let encryptedTextLen = encryptedData.count
                
                var plainData = Data(count: kAsymmetricCryptoManagerCypheredBufferSize)
                let plainText = plainData.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8> in
                    return bytes
                })
                var plainTextLen = plainData.count
                
                let status = SecKeyDecrypt(privateKeyRef, .PKCS1, encryptedText, encryptedTextLen, plainText, &plainTextLen)
                
                DispatchQueue.main.async(execute: { () -> Void in
                    if status == errSecSuccess {
                        //NSData length
                        plainData.count = plainTextLen
                        
                        if let string = NSString(data: plainData as Data, encoding: String.Encoding.utf8.rawValue) as? String {
                            completion(true, string, nil)
                        } else { completion(false, nil, .unableToDecrypt) }
                    } else { completion(false, nil, .unableToDecrypt) }
                    plainText.deinitialize()
                })
                return
            } else { DispatchQueue.main.async(execute: { completion(false, nil, .keyNotFound) }) }
        }
    }
    
    
}
