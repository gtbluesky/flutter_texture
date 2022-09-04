#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import Cocoa
import FlutterMacOS
#endif

public class SwiftFlutterTexturePlugin: NSObject, FlutterPlugin {
    private var textureMap: [Int64: MyTexture] = [:]
    private let registrar: FlutterPluginRegistrar
    static let INVALID_TEXTURE_ID = -1

    private init(_ registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let messenger: FlutterBinaryMessenger = registrar.messenger()
        #elseif os(macOS)
        let messenger: FlutterBinaryMessenger = registrar.messenger
        #endif
        let channel = FlutterMethodChannel(name: "texture_channel", binaryMessenger: messenger)
        let instance = SwiftFlutterTexturePlugin(registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "registerTexture":
            let texture = MyTexture(registrar)
            #if os(iOS)
            let textureId = registrar.textures().register(texture)
            #elseif os(macOS)
            let textureId = registrar.textures.register(texture)
            #endif
            textureMap[textureId] = texture
            texture.textureId = textureId
            let reply = ["textureId": textureId]
            result(reply)
        case "renderTexture":
            guard let dict = call.arguments as? Dictionary<String, Any> else {
                result(nil)
                return
            }
            let textureId = Int64(dict["textureId"] as? Int ?? SwiftFlutterTexturePlugin.INVALID_TEXTURE_ID)
            let url = dict["url"] as? String ?? ""
            let width = dict["width"] as? Int ?? 0
            let height = dict["height"] as? Int ?? 0
            if textureId >= 0 && !url.isEmpty {
                textureMap[textureId]?.renderTexture(width: width, height: height)
            }
            result(nil)
        case "unregisterTexture":
            guard let dict = call.arguments as? Dictionary<String, Any> else {
                result(nil)
                return
            }
            let textureId = Int64(dict["textureId"] as? Int ?? SwiftFlutterTexturePlugin.INVALID_TEXTURE_ID)
            if textureId >= 0 {
                #if os(iOS)
                registrar.textures().unregisterTexture(textureId)
                #elseif os(macOS)
                registrar.textures.unregisterTexture(textureId)
                #endif
                textureMap.removeValue(forKey: textureId)
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

class MyTexture: NSObject, FlutterTexture {
    private var pixelBuffer: CVPixelBuffer?
    private weak var registrar: FlutterPluginRegistrar?
    var textureId: Int64 = -1

    init(_ registrar: FlutterPluginRegistrar?) {
        self.registrar = registrar
    }

    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        guard let pixelBuffer = pixelBuffer else {
            return nil
        }
        return Unmanaged<CVPixelBuffer>.passRetained(pixelBuffer)
    }

    func renderTexture(width: Int, height: Int) {
//        kCVPixelBufferCGImageCompatibilityKey，表示与CGImage类型兼容；
//
//        kCVPixelBufferCGBitmapContextCompatibilityKey，兼容Core Graphics bitmap contexts；
//
//        kCVPixelBufferIOSurfacePropertiesKey，如果使用CVPixelBuffer创建OpenGL的纹理时，这个属性必须要设置，表示内存共享。否则，无法成功创建OpenGL的纹理。

        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ] as [String: Any]
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, options as CFDictionary?, &pixelBuffer)
        guard let pixelBuffer = pixelBuffer else {
            return
        }
        let lockFlags = CVPixelBufferLockFlags(rawValue: 0)
        CVPixelBufferLockBaseAddress(pixelBuffer, lockFlags)
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, lockFlags)
        }

        let bufferAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: bufferAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: rgbColorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        )
        #if os(iOS)
        context?.setFillColor(UIColor.blue.cgColor)
        #elseif os(macOS)
        context?.setFillColor(NSColor.blue.cgColor)
        #endif
        context?.fill(CGRect(x: 0, y: 0, width: width, height: height))

//        context?.setAllowsAntialiasing(allowAntialiasing)
//
//        context?.translateBy(x: CGFloat(-srcX), y: CGFloat(Double(srcY + height) - fh))
//        context?.scaleBy(x: sx, y: sy)
//        context?.concatenate(page.getRotationTransform())
//        context?.drawPDFPage(page)
        context?.flush()

        self.pixelBuffer = pixelBuffer
        #if os(iOS)
        registrar?.textures().textureFrameAvailable(textureId)
        #elseif os(macOS)
        registrar?.textures.textureFrameAvailable(textureId)
        #endif
    }
}