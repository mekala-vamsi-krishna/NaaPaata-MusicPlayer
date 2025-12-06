//
//  PurchaseError.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 12/5/25.
//

import Foundation

enum PurchaseError: Error, Identifiable {
    case userCancelled
    case pending
    case networkError
    case authenticationFailed
    case productNotFound
    case loadProductsFailed(String)
    case unknown(String)
    
    var id: String {
        switch self {
        case .userCancelled:
            return "userCancelled"
        case .pending:
            return "pending"
        case .networkError:
            return "networkError"
        case .authenticationFailed:
            return "authenticationFailed"
        case .productNotFound:
            return "productNotFound"
        case .loadProductsFailed:
            return "loadProductsFailed"
        case .unknown:
            return "unknown"
        }
    }
    
    var title: String {
        switch self {
        case .userCancelled:
            return "Purchase Cancelled"
        case .pending:
            return "Purchase Pending"
        case .networkError:
            return "Connection Error"
        case .authenticationFailed:
            return "Sign In Failed"
        case .productNotFound:
            return "Product Not Available"
        case .loadProductsFailed:
            return "Unable to Load Products"
        case .unknown:
            return "Purchase Failed"
        }
    }
    
    var message: String {
        switch self {
        case .userCancelled:
            return "Your purchase was cancelled. No charges were made to your account."
        case .pending:
            return "Your purchase is pending approval. You'll be notified when it's complete."
        case .networkError:
            return "Unable to connect to the App Store. Please check your internet connection and try again."
        case .authenticationFailed:
            return "We couldn't verify your Apple ID credentials. Please sign in to your Apple ID and try again."
        case .productNotFound:
            return "The selected subscription plan is currently unavailable. Please try again later."
        case .loadProductsFailed(let error):
            return "We couldn't load subscription plans. Please try again later.\n\nError: \(error)"
        case .unknown(let error):
            return "An unexpected error occurred. Please try again.\n\nError: \(error)"
        }
    }
    
    var icon: String {
        switch self {
        case .userCancelled:
            return "xmark.circle.fill"
        case .pending:
            return "clock.fill"
        case .networkError:
            return "wifi.slash"
        case .authenticationFailed:
            return "person.crop.circle.badge.exclamationmark"
        case .productNotFound:
            return "exclamationmark.triangle.fill"
        case .loadProductsFailed:
            return "exclamationmark.triangle.fill"
        case .unknown:
            return "exclamationmark.circle.fill"
        }
    }
}
