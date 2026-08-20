import Flutter
import Foundation
import GoogleMaps
import AVFoundation
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let speechSynthesizer = AVSpeechSynthesizer()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    configureGoogleMaps()
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: "itarevo.google_maps",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handleGoogleMapsCall(call, result: result)
    }

    let speechChannel = FlutterMethodChannel(
      name: "itarevo.speech",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    speechChannel.setMethodCallHandler { [weak self] call, result in
      self?.handleSpeechCall(call, result: result)
    }
  }

  private func handleSpeechCall(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    switch call.method {
    case "speak":
      guard let arguments = call.arguments as? [String: Any],
            let text = arguments["text"] as? String,
            let localeId = arguments["localeId"] as? String,
            !text.isEmpty else {
        result(FlutterError(code: "invalid_speech", message: "Speech text is required.", details: nil))
        return
      }
      speechSynthesizer.stopSpeaking(at: .immediate)
      let utterance = AVSpeechUtterance(string: text)
      utterance.voice = AVSpeechSynthesisVoice(language: localeId)
      guard utterance.voice != nil else {
        result(FlutterError(code: "unsupported_voice", message: "The requested voice is unavailable.", details: nil))
        return
      }
      speechSynthesizer.speak(utterance)
      result(true)
    case "stop":
      speechSynthesizer.stopSpeaking(at: .immediate)
      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func googleMapsAPIKey() -> String? {
    guard let value = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String else {
      return nil
    }

    let key = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !key.isEmpty, !key.contains("$(") else {
      return nil
    }
    return key
  }

  private func configureGoogleMaps() {
    guard let key = googleMapsAPIKey() else {
      return
    }
    GMSServices.provideAPIKey(key)
  }

  private func handleGoogleMapsCall(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard let key = googleMapsAPIKey() else {
      if call.method == "isConfigured" {
        result(false)
      } else {
        result(FlutterError(
          code: "missing_configuration",
          message: "Google Maps is not configured for this build.",
          details: nil
        ))
      }
      return
    }

    switch call.method {
    case "isConfigured":
      result(true)
    case "searchPlaces":
      searchPlaces(call.arguments as? [String: Any], key: key, result: result)
    case "computeRoute":
      computeRoute(call.arguments as? [String: Any], key: key, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func searchPlaces(
    _ arguments: [String: Any]?,
    key: String,
    result: @escaping FlutterResult
  ) {
    guard let query = arguments?["query"] as? String, !query.isEmpty else {
      result(FlutterError(code: "invalid_query", message: "A place query is required.", details: nil))
      return
    }

    let limit = min(max(arguments?["limit"] as? Int ?? 8, 1), 20)
    let body: [String: Any] = [
      "textQuery": query,
      "maxResultCount": limit,
    ]

    postGoogleRequest(
      url: URL(string: "https://places.googleapis.com/v1/places:searchText")!,
      body: body,
      headers: [
        "X-Goog-Api-Key": key,
        "X-Goog-FieldMask": "places.id,places.displayName,places.formattedAddress,places.location,places.rating,places.priceLevel,places.currentOpeningHours,places.types,places.primaryType,places.googleMapsUri",
      ]
    ) { response in
      switch response {
      case .failure(let error):
        result(FlutterError(code: "places_request_failed", message: error.localizedDescription, details: nil))
      case .success(let json):
        let places = (json["places"] as? [[String: Any]] ?? []).map { place in
          let displayName = (place["displayName"] as? [String: Any])?["text"] as? String
          let location = place["location"] as? [String: Any]
          let openingHours = place["currentOpeningHours"] as? [String: Any]
          var mapped: [String: Any] = [
            "id": place["id"] as? String ?? "google-place",
            "name": displayName ?? "Google place",
          ]
          if let address = place["formattedAddress"] as? String {
            mapped["address"] = address
          }
          if let location {
            mapped["location"] = location
          }
          if let rating = place["rating"] {
            mapped["rating"] = rating
          }
          if let priceLevel = place["priceLevel"] {
            mapped["priceLevel"] = priceLevel
          }
          if let types = place["types"] {
            mapped["types"] = types
          }
          if let isOpenNow = openingHours?["openNow"] {
            mapped["isOpenNow"] = isOpenNow
          }
          return mapped
        }
        result(places)
      }
    }
  }

  private func computeRoute(
    _ arguments: [String: Any]?,
    key: String,
    result: @escaping FlutterResult
  ) {
    guard let origin = arguments?["origin"] as? String,
          let destination = arguments?["destination"] as? String,
          !origin.isEmpty,
          !destination.isEmpty else {
      result(FlutterError(code: "invalid_route", message: "Origin and destination are required.", details: nil))
      return
    }

    let travelMode = arguments?["travelMode"] as? String ?? "DRIVE"
    let body: [String: Any] = [
      "origin": ["address": origin],
      "destination": ["address": destination],
      "travelMode": travelMode,
      "computeAlternativeRoutes": false,
      "languageCode": "en-GB",
      "units": "METRIC",
    ]

    postGoogleRequest(
      url: URL(string: "https://routes.googleapis.com/directions/v2:computeRoutes")!,
      body: body,
      headers: [
        "X-Goog-Api-Key": key,
        "X-Goog-FieldMask": "routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline",
      ]
    ) { response in
      switch response {
      case .failure(let error):
        result(FlutterError(code: "route_request_failed", message: error.localizedDescription, details: nil))
      case .success(let json):
        guard let route = (json["routes"] as? [[String: Any]])?.first else {
          result(nil)
          return
        }
        let duration = (route["duration"] as? String ?? "0s")
          .replacingOccurrences(of: "s", with: "")
        result([
          "distanceMeters": route["distanceMeters"] as? Int ?? 0,
          "durationSeconds": Double(duration) ?? 0,
          "encodedPolyline": (route["polyline"] as? [String: Any])?["encodedPolyline"],
        ])
      }
    }
  }

  private func postGoogleRequest(
    url: URL,
    body: [String: Any],
    headers: [String: String],
    completion: @escaping (Result<[String: Any], Error>) -> Void
  ) {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)

    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error {
        DispatchQueue.main.async { completion(.failure(error)) }
        return
      }
      guard let httpResponse = response as? HTTPURLResponse,
            let data,
            (200...299).contains(httpResponse.statusCode) else {
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        let error = NSError(domain: "GoogleMaps", code: status, userInfo: [NSLocalizedDescriptionKey: "Google Maps request failed (HTTP \(status))."])
        DispatchQueue.main.async { completion(.failure(error)) }
        return
      }
      do {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        DispatchQueue.main.async { completion(.success(json)) }
      } catch {
        DispatchQueue.main.async { completion(.failure(error)) }
      }
    }.resume()
  }
}
