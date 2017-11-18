//
//  ViewController.swift
//  BLE-Test
//
//  Created by Christian Mansch on 07.10.17.
//  Copyright © 2017 Christian.Mansch. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var servicesTextView: UITextView!
    @IBOutlet weak var buttonConnect: UIButton!
    @IBOutlet weak var buttonDisconnect: UIButton!
    @IBOutlet weak var characteristicsTextView: UITextView!
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var headphoneTag: CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonDisconnect.isEnabled = false
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOn :
            central.scanForPeripherals(withServices: nil, options: nil)
            print("The state is powerdOn")
        case .poweredOff :
            print("The state is powerdOff")
        case .unauthorized :
            print("The state is unauthorized")
        case .unknown :
            print("The state is unknown")
        case .unsupported :
            print("The state is unsupported")
        case .resetting :
            print("The state is resetting")
        }
        print("Scanning: \(central.isScanning)")
        statusLabel.text = "Scanning: \(central.isScanning ? "started" : "stopped")"
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //if peripheral.identifier.uuidString == "800C82B2-2EFE-0153-17F1-53C1B5D88762"
        if peripheral.identifier.uuidString == "B2B4ABA2-6B24-DD10-303E-5FBD17BCE081"
        {
            print("The Name is: \(peripheral.name ?? "nil")")
            label1.text = "Connected to: \(peripheral.name!)"
            central.isScanning ? central.stopScan() : print("scanning already stopped")
            headphoneTag = peripheral
            headphoneTag?.delegate = self
            
            if let aventho = headphoneTag {
                central.connect(aventho, options: nil)
            }
        }
        /*else {
            print(peripheral.identifier.uuidString)
            print(peripheral.name ?? "no name")
        }*/
        print("Scanning: \(central.isScanning)")
        statusLabel.text? = "Scanning: \(central.isScanning ? "started" : "stopped")"
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("An Error has occoured: \(String(describing: error?.localizedDescription))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                servicesTextView.text.append("\n\(service.uuid)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("Error discovering Characteristics: \(String(describing: error?.localizedDescription))")
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                characteristicsTextView.text.append("\n\(characteristic.uuid)")
                print(characteristic.uuid)
                peripheral.readValue(for: characteristic)
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            
            // Hier wandle ich explizit den Battery-Level in einen Integer um (nur zum Test ob das geht).
            if characteristic.service.uuid.uuidString == "180F"
            {
                print("Found")
                let byteArray = [UInt8](value)
                print(byteArray)
                for byte in byteArray{
                    print(byte)
                }
            }
            
            if let data = NSString(data: value, encoding: String.Encoding.utf8.rawValue)
            {
                characteristicsTextView.text.append("\n\(data)")
            }
            else {
                print(value.first ?? 0)
            }
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        switch peripheral.state {
        case .disconnected:
            label1.text = "Disconnected"
        case .disconnecting:
            label1.text = "Disconnecting"
        default:
            break
        }
    }
    
    @IBAction func connect(_ sender: UIButton) {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        self.buttonConnect.isEnabled = false
        self.buttonDisconnect.isEnabled = true
        self.servicesTextView.text = " Services: "
        self.characteristicsTextView.text = "Characteristics: "
    }
 
    
    
    @IBAction func disconnect(_ sender: UIButton) {
        centralManager.cancelPeripheralConnection(headphoneTag!)
        self.buttonDisconnect.isEnabled = false
        self.buttonConnect.isEnabled = true
    }
 
}
