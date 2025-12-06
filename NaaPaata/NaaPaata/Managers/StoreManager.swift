//
//  StoreManager.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 11/30/25.
//

import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var subscriptions: [Product] = []
    @Published var purchasedSubscriptions: [Product] = []
    @Published var isSubscribed: Bool = false
    
    // Error and success states for UI feedback
    @Published var purchaseError: PurchaseError? = nil
    @Published var purchaseSuccessMessage: String? = nil
    @Published var showRestoredAlert: Bool = false
    @Published var restoredMessage: String = ""
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        // Start listening for transaction updates immediately
        updates = Task(priority: .background) {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await updateSubscriptionStatus()
                }
            }
        }
        
        Task { await loadProducts() }
    }
    
    deinit {
        updates?.cancel()
    }
    
    /// Fetch your subscription products by Product IDs
    func loadProducts() async {
        do {
            let productIDs = [
                "Naa_Paata_1M",
                "Naa_Paata_6M",
                "Naa_Paata_12M"
            ]
            let storeProducts = try await Product.products(for: productIDs)
            self.subscriptions = storeProducts.sorted(by: { $0.price < $1.price })
        } catch {
            print("Failed to load products: \(error)")
            self.purchaseError = .loadProductsFailed(error.localizedDescription)
        }
    }
    
    /// Check if user currently has entitlement
    func updateSubscriptionStatus() async {
        var activeSubscriptions: [Product] = []
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if let product = subscriptions.first(where: { $0.id == transaction.productID }) {
                    activeSubscriptions.append(product)
                }
            }
        }
        
        purchasedSubscriptions = activeSubscriptions
        isSubscribed = !activeSubscriptions.isEmpty
    }
    
    /// Purchase a subscription
    func purchase(_ product: Product) async {
        // Reset previous error states
        self.purchaseError = nil
        self.purchaseSuccessMessage = nil
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await updateSubscriptionStatus()
                    await transaction.finish()
                    self.purchaseSuccessMessage = "Welcome to Premium! Your subscription is now active."
                } else {
                    // Verification failed
                    self.purchaseError = .authenticationFailed
                }
            case .userCancelled:
                print("Purchase was cancelled by the user.")
                self.purchaseError = .userCancelled
            case .pending:
                print("Purchase is pending approval.")
                self.purchaseError = .pending
            @unknown default:
                self.purchaseError = .unknown("An unexpected result occurred.")
            }
        } catch {
            print("Purchase failed: \(error)")
            // Handle specific StoreKit errors
            if let storeError = error as? StoreKitError {
                switch storeError {
                case .userCancelled:
                    self.purchaseError = .userCancelled
                case .networkError:
                    self.purchaseError = .networkError
                default:
                    self.purchaseError = .unknown(storeError.localizedDescription)
                }
            } else {
                // Check for network-related errors
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain {
                    self.purchaseError = .networkError
                } else {
                    self.purchaseError = .unknown(error.localizedDescription)
                }
            }
        }
    }
    
    /// Restore Purchase
    func restorePurchases() async {
        // Reset previous states
        self.purchaseError = nil
        self.showRestoredAlert = false
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            
            if isSubscribed {
                self.restoredMessage = "Your purchases have been restored successfully!"
                self.showRestoredAlert = true
            } else {
                self.restoredMessage = "No previous purchases found to restore."
                self.showRestoredAlert = true
            }
        } catch {
            print("Restore failed: \(error)")
            self.purchaseError = .unknown("Failed to restore purchases. Please try again.")
        }
    }
    

}
